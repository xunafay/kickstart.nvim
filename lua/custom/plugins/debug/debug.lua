return {
  'DePaWSiT/nvim-dap', -- WARN: fork with windows path fix
  --'mfussenegger/nvim-dap',
  dependencies = {
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'folke/snacks.nvim',
    'j-hui/fidget.nvim',
    {
      'NicholasMata/nvim-dap-cs',
      branch = 'saul-marquez-feat/win-compatibility',
    },
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F11>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F10>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F9>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
  },
  config = function()
    local dap = require 'dap'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        'netcoredbg',
        'codelldb',
      },
    }

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and {
          Breakpoint = '',
          BreakpointCondition = '',
          BreakpointRejected = '',
          LogPoint = '',
          Stopped = '',
        }
      or {
        Breakpoint = '●',
        BreakpointCondition = '⊜',
        BreakpointRejected = '⊘',
        LogPoint = '◆',
        Stopped = '⭔',
      }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    require('custom.debug.languages.cs').configure(dap)

    dap.set_log_level 'TRACE'
  end,
}
