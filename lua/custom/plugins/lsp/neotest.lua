return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    {
      'nsidorenco/neotest-vstest',
      config = function()
        vim.g.neotest_vstest = {
          dap_settings = {
            type = 'coreclr',
          },
        }
      end,
    },
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-vstest',
        require 'rustaceanvim.neotest',
      },
    }
  end,
}
