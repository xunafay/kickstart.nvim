return {
  dir = 'C:\\Users\\H.Witvrouwen\\AppData\\Local\\nvim\\explorer.dotnet.nvim',
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
