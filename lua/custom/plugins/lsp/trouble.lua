return {
  'folke/trouble.nvim',
  opts = {
    modes = {
      workspace_diagnostics = {
        mode = 'diagnostics',
        source = 'diagnostics_pull',
        title = 'Workspace Diagnostics',
        auto_refresh = true,
        auto_close = false,
      },
    },
  }, -- for default options, refer to the configuration section for custom setup.
  cmd = 'Trouble',
  keys = {
    {
      '<leader>lS',
      '<cmd>Trouble symbols toggle focus=false<cr>',
      desc = 'Open Workspace [S]ymbols',
    },
    {
      '<leader>ll',
      '<cmd>Trouble workspace_diagnostics toggle filter.severity=vim.diagnostic.severity.ERROR<cr>',
      desc = '[L]ist Workspace Diagnostics',
    },
    {
      '<leader>lL',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = '[L]ist Diagnostics for Current Buffer',
    },
    {
      '<leader>lQ',
      '<cmd>Trouble qflist toggle<cr>',
      desc = '[L]SP [Q]uickfix List (Trouble)',
    },
  },
}
