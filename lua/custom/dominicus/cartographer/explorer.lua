---@diagnostic disable: await-in-sync
local Actions = require 'snacks.explorer.actions'
local Tree = require 'snacks.explorer.tree'
local Builtin = require 'snacks.picker.source.explorer' -- reuse its search/items logic

local M = {}
M.actions = Actions.actions

local function norm(p)
  return svim.fs.normalize(vim.fn.fnamemodify(p, ':p')):gsub('/$', '')
end

---@param slnx_path string
local function solution_dir(slnx_path)
  return norm(vim.fs.dirname(slnx_path))
end

---@param sol_dir string
---@param name string
local function virtual_folder_path(sol_dir, name)
  -- stable synthetic folder path, does not have to exist
  return norm(sol_dir .. '/.sln/' .. name)
end

---@param sol_dir string
---@param nodes table
local function inject_solution_tree(sol_dir, nodes)
  local root = Tree:find(sol_dir)

  ---@param parent snacks.picker.explorer.Node
  ---@param base string
  ---@param node table
  local function add(parent, base, node)
    if node.kind == 'directory' then
      local p = virtual_folder_path(sol_dir, base .. '/' .. node.name)
      local n = Tree:find(p)
      n.name, n.dir, n.type = node.name, true, 'directory'
      parent.children[n.name] = n
      n.parent = parent
      for _, ch in ipairs(node.children or {}) do
        add(n, base .. '/' .. node.name, ch)
      end
      return
    end

    if node.kind == 'project' then
      -- IMPORTANT: project path is a REAL DIRECTORY on disk
      local proj_dir = norm(node.path)
      local n = Tree:find(proj_dir)
      n.name, n.dir, n.type = node.name, true, 'directory'
      parent.children[n.name] = n
      n.parent = parent
      -- Do NOT add children here; builtin explorer will populate when opened.
      return
    end
  end

  for _, n in ipairs(nodes or {}) do
    add(root, '', n)
  end
end

---@param opts table
function M.setup(opts)
  -- Start from the builtin explorer source config and keep it.
  -- It wires up searching-mode + confirm + formatter, etc. citeturn2search0
  opts = Builtin.setup(opts)

  -- Optional: ensure tree mode
  opts.tree = true
  opts.watch = true

  return opts
end

function M.dotnet_explorer(opts, ctx)
  -- We want the picker cwd to be the solution dir.
  local slnx = opts.slnx and norm(opts.slnx) or nil
  if not slnx then
    Snacks.notify.warn "dotnet_explorer: pass opts.slnx = '/abs/path/to/MySolution.slnx'"
    return {}
  end

  local sol_dir = solution_dir(slnx)
  if ctx.picker:cwd() ~= sol_dir then
    ctx.picker:set_cwd(sol_dir)
  end

  -- Parse solution
  local lector = require 'custom.dominicus.lector' -- adjust to your real module path
  local solution = lector.parse_projects(slnx)
  if not solution then
    return {}
  end

  -- Inject solution folders + project roots into the same Tree
  Tree:refresh(sol_dir)
  inject_solution_tree(sol_dir, solution.tree)

  -- Delegate the actual listing/searching/tree rendering to the builtin explorer finder.
  -- That gives you: expanding dirs, showing children, git/diagnostics/watch, etc. citeturn2search0
  return Builtin.explorer(opts, ctx)
end

return M
