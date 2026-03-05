return {
  name = 'dominicus-guidance',
  dir = vim.fn.stdpath 'config' .. '/lua/custom/dominicus/cartographer',
  lazy = false,
  enable = true,
  priority = 1000,
  dependencies = {
    { 'folke/snacks.nvim' },
  },
  config = function()
    require('custom.dominicus.cartographer').pick_solution()
  end,
  keys = {
    {
      '<leader>de',
      function()
        require('custom.dominicus.cartographer').open_dotnet()
      end,
      desc = 'Guidance - Pick Solution',
    },
  },
}
