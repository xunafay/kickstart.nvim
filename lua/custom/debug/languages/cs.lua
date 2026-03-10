local Snacks = require 'snacks'

local M = {}

local function get_extensions()
  local config_file = vim.fs.joinpath(vim.fn.stdpath 'config' .. '/lua/custom/debug/chipsoft/init.lua')
  if vim.uv.fs_stat(config_file) then
    local ok, _ = pcall(require, 'custom.debug.chipsoft')
    if not ok then
      return {}
    end
    return require 'custom.debug.chipsoft'
  else
    return {}
  end
end

local function get_git_root()
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 or not git_root then
    git_root = vim.fn.getcwd()
  end
  return git_root
end

local function get_dll_path()
  local co = coroutine.running()

  Snacks.picker.files {
    title = 'Select Solution',
    finder = 'files',
    args = { '--glob', '*.dll' },
    cwd = get_git_root(),
    show_empty = false,
    auto_confirm = true,
    hidden = true,
    ignored = true,
    actions = {
      confirm = function(picker, item)
        picker:close()
        vim.notify('Selected DLL: ' .. vim.inspect(item._path), vim.log.levels.INFO)
        coroutine.resume(co, item._path)
      end,
    },
  }

  return coroutine.yield()
end

function M.build_solution(on_complete)
  local progress = require 'fidget.progress'

  local handle = progress.handle.create {
    title = 'dotnet build',
    message = 'Building solution...',
    lsp_client = { name = 'dotnet' },
  }

  handle:report { message = 'Running dotnet build...' }
  vim.system({ 'dotnet', 'build', vim.g.roslyn_nvim_selected_solution, '-c', 'Debug' }, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 then
        handle:finish 'Build failed'
        vim.notify(obj.stdout .. obj.stderr, vim.log.levels.ERROR)
        on_complete(false)
      else
        handle:finish 'Build succeeded'
        on_complete(true)
      end
    end)
  end)
end

function M.configure(dap)
  local netcoredbg = 'netcoredbg'
  if vim.fn.has 'win32' == 1 then
    netcoredbg = 'netcoredbg.cmd'
  end

  -- TODO: what about vsdb? kmiterror/dotnet-debug.nvim
  dap.adapters.coreclr = {
    type = 'executable',
    command = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'bin', netcoredbg),
    args = { '--interpreter=vscode' },
    options = {
      detached = false,
      justMyCode = false,
      stopAtEntry = true,
    },
  }

  local configs = {
    {
      type = 'coreclr',
      name = 'Attach (pick process)',
      request = 'attach',
      processId = require('dap.utils').pick_process,
      justMyCode = false,
    },
    {
      type = 'coreclr',
      name = 'Launch .NET',
      request = 'launch',
      justMyCode = false,
      console = 'integratedTerminal',
      program = get_dll_path,
    },
  }

  for _, config in ipairs(configs) do
    table.insert(dap.configurations.cs, config)
  end

  local extensions = get_extensions()
  if extensions.configure_listeners then
    extensions.configure_listeners(dap, get_git_root)
  end

  if extensions.configurations then
    local custom_configs = extensions.configurations(get_git_root, M.build_solution)
    for _, config in ipairs(custom_configs) do
      table.insert(dap.configurations.cs, config)
    end
  end
end

return M
