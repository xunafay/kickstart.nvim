---@type trouble.Source
local M = {}

local function diagnostics()
  return require 'trouble.sources.diagnostics'
end

M.highlights = {
  Message = 'TroubleText',
  ItemSource = 'Comment',
  Code = 'Comment',
}

function M.setup()
  diagnostics().setup()
end

---@param cb trouble.Source.Callback
---@param ctx trouble.Source.ctx
function M.get(cb, ctx)
  vim.lsp.buf.workspace_diagnostics()
  diagnostics().get(cb, ctx)
end

return M
