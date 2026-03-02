return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nsidorenco/neotest-vstest',
    -- 'Issafalcon/neotest-dotnet',
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-vstest',
        -- require 'neotest-dotnet',
        require 'rustaceanvim.neotest',
      },
    }
  end,
}
