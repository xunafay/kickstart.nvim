return {
  name = 'solution-workspaces',
  dir = vim.fn.stdpath 'config' .. '/lua/custom/solution_workspaces',
  lazy = false,
  priority = 1000,
  dependencies = {
    { 'folke/snacks.nvim' },
  },
  config = function()
    require('custom.solution_workspaces.workspace').bootstrap()
  end,
}
