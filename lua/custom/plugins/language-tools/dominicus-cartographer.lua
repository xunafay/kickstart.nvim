return {
  name = 'dominicus-cartographer',
  dir = vim.fn.stdpath 'config' .. '/lua/custom/dominicus/cartographer',
  lazy = false,
  enable = true,
  priority = 1000,
  dependencies = {
    { 'folke/snacks.nvim' },
  },
  config = function()
    require('custom.dominicus.cartographer.snacks').setup()
    require('custom.dominicus.cartographer.snacks').pick_solution()
    -- require('custom.dominicus.cartographer').pick_solution()
  end,
  keys = {
    {
      '<leader>de',
      function()
        require('snacks').picker.pick {
          source = 'cartographer',
          title = 'Solution Explorer',
        }
      end,
      desc = '[D]ominicus [E]xplorer',
    },
  },
}
