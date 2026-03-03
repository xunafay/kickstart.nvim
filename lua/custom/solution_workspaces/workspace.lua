local parser = require 'custom.solution_workspaces.parser'
local cache = require 'custom.solution_workspaces.cache'
local picker = require 'custom.solution_workspaces.picker'

local M = {}
local uv = vim.loop

local function make_symlink(src, dest)
  local is_windows = uv.os_uname().sysname == 'Windows_NT'

  local stat = uv.fs_stat(src)
  if not stat then
    vim.notify('make_symlink: src does not exist: ' .. src, vim.log.levels.ERROR)
    return
  end

  if is_windows then
    src = src:gsub('/', '\\')
    dest = dest:gsub('/', '\\')

    local cmd
    if stat.type == 'directory' then
      cmd = string.format('cmd /c mklink /J "%s" "%s"', dest, src)
    else
      cmd = string.format('cmd /c mklink "%s" "%s"', dest, src)
    end

    local output = vim.fn.system(cmd)
  else
    local opts = { junction = true }
    if stat.type == 'directory' then
      opts.dir = true
    end

    local ok, err = uv.fs_symlink(src, dest, opts)
    if not ok then
      vim.notify('Failed to symlink: ' .. err, vim.log.levels.ERROR)
    end
  end
end

local function materialize_tree(nodes, base_path)
  for _, node in ipairs(nodes) do
    if node.kind == 'directory' then
      local dir_path = base_path .. '/' .. node.name
      vim.fn.mkdir(dir_path, 'p')
      materialize_tree(node.children, dir_path)
    elseif node.kind == 'project' then
      local link_path = base_path .. '/' .. node.name
      if vim.fn.isdirectory(link_path) == 0 then
        make_symlink(node.path, link_path)
      end
    end
  end
end

local function find_git_root(path)
  local dir = path
  while dir and dir ~= vim.loop.cwd() do
    if vim.fn.filereadable(dir .. '/.gitignore') == 1 then
      return dir
    end
    dir = vim.fs.dirname(dir)
    if dir == '' or dir == nil then
      break
    end
  end
end

--- @param solution Solution
local function create_workspace(solution)
  local solution_name = vim.fn.fnamemodify(solution.path, ':t:r')
  local hash = vim.fn.sha256(solution.path):sub(1, 8)
  local tmpdir = vim.fn.stdpath 'cache' .. '/' .. solution_name .. '_' .. hash
  vim.fn.mkdir(tmpdir, 'p')

  local git_root = find_git_root(solution.path)
  if git_root then
    -- TODO: get git working
    -- local git_link = tmpdir .. '/.git'
    -- if vim.fn.isdirectory(git_link) == 0 then
    --   make_symlink(git_root .. '/.git', git_link)
    -- end

    local gitignore_link = tmpdir .. '/.gitignore'
    if vim.fn.filereadable(gitignore_link) == 0 then
      make_symlink(git_root .. '/.gitignore', gitignore_link)
    end
  end
  -- make_symlink(solution.path, tmpdir .. '/' .. solution_name .. '.slnx') WARN: actually this breaks roslyn

  materialize_tree(solution.tree, tmpdir)

  vim.cmd('cd ' .. tmpdir)

  -- restart LSP cleanly
  vim.lsp.stop_client(vim.lsp.get_clients())
  vim.defer_fn(function()
    vim.cmd 'LspStart'
  end, 100)

  -- fix snacks.explorer
  local snacks = require 'snacks'
  local pickers = snacks.picker.get {} -- TODO: no pickers are found at this point, investigate
  for _, snacks_picker in ipairs(pickers) do
    snacks_picker:close()
  end
  snacks.explorer.open {}

  return tmpdir
end

function M.bootstrap()
  local arg = vim.fn.argv(0)
  if not arg or arg == '' then
    return
  end

  local full = vim.fn.fnamemodify(arg, ':p')
  if vim.fn.isdirectory(full) == 0 then
    return
  end

  local slnx_files = vim.fn.globpath(full, '*.slnx', false, true)
  if #slnx_files == 0 then
    return
  end

  picker.pick_slnx(slnx_files, function(selected)
    local solution = parser.parse_projects(selected)
    if not solution or not solution.tree or #solution.tree == 0 then
      vim.notify('Failed to parse solution. Cannot create workspace.', vim.log.levels.ERROR)
      return
    end

    local ws = create_workspace(solution)

    -- TODO: we don't actually load the cache ever? we just recreate the workspace every time?
    local data = cache.load()
    data[selected] = ws
    cache.save(data)
  end)
end

function M.rebuild()
  local cwd = vim.fn.getcwd()
  local data = cache.load()

  for slnx, ws in pairs(data) do
    if ws == cwd then
      vim.fn.delete(ws, 'rf')

      local solution = parser.parse_projects(slnx)
      if not solution then
        print 'Failed to parse solution. Cannot rebuild workspace.'
        return
      end
      local new_ws = create_workspace(solution)

      data[slnx] = new_ws
      cache.save(data)

      print 'Workspace rebuilt.'
      return
    end
  end

  print 'No cached workspace found.'
end

return M
