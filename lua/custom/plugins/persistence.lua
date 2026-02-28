return {
  'folke/persistence.nvim',
  event = 'BufReadPre', -- this will only start session saving when an actual file was opened
  opts = {
    -- add any custom options here
  },
  config = function()
    require('persistence').setup {}
    vim.keymap.set('n', '<leader>qs', function()
      require('persistence').load()
    end)
    vim.keymap.set('n', '<leader>qS', function()
      require('persistence').select()
    end)
    vim.keymap.set('n', '<leader>ql', function()
      require('persistence').load { last = true }
    end)
    vim.keymap.set('n', '<leader>qd', function()
      require('persistence').stop()
    end)
  end,
}
