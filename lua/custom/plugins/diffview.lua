return {
  'sindrets/diffview.nvim',
  config = function()
    require('diffview').setup {
      keymaps = {
        {
          'n',
          'cc',
          '<Cmd>Git commit <bar> wincmd J<CR>',
          { desc = 'Commit staged changes' },
        },
        {
          'n',
          'ca',
          '<Cmd>Git commit --amend <bar> wincmd J<CR>',
          { desc = 'Amend the last commit' },
        },
        {
          'n',
          'c<space>',
          ':Git commit ',
          { desc = 'Populate command line with ":Git commit "' },
        },
      },
    }
    vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#20303b' })
    vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#37222c' })
    vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#1f2231' })
    vim.api.nvim_set_hl(0, 'DiffText', { bg = '#394b70' })
    vim.opt.fillchars:append 'diff:╱'

    vim.keymap.set('n', '<leader>difo', '<Cmd>:DiffviewOpen<Cr>', { desc = 'Open diffview' })
    vim.keymap.set('n', '<leader>difc', '<Cmd>:DiffviewClose<Cr>', { desc = 'Close diffview' })
    vim.keymap.set('n', '<leader>difh', '<Cmd>:DiffviewFileHistory<Cr>', { desc = 'File history' })
  end,
}
