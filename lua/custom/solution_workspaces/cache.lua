local M = {}

local cache_file = vim.fn.stdpath 'cache' .. '/slnx_workspace.json'

--- Loads the workspace cache from the cache file
--- @returns table A table mapping .slnx file paths to workspace directories
function M.load()
  if vim.fn.filereadable(cache_file) == 0 then
    return {}
  end

  local content = table.concat(vim.fn.readfile(cache_file), '\n')
  return vim.json.decode(content) or {}
end

--- Saves the workspace cache to the cache file
--- @param data table A table mapping .slnx file paths to workspace directories
function M.save(data)
  vim.fn.writefile(vim.split(vim.json.encode(data), '\n'), cache_file)
end

return M
