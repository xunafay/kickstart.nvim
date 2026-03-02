return {
  dir = vim.fn.resolve(vim.fn.stdpath 'config' .. '/lua/explorer.dotnet.nvim'),
  config = function()
    require('dotnet_explorer').setup {
      renderer = {
        width = 60,
        side = 'left',
      },
    }
  end,
  keys = {
    { '<leader>tse', '<cmd>ToggleSolutionExplorer<cr>', desc = 'Toggle Solution Explorer' },
  },
}
