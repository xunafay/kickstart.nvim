return {
  'nvzone/floaterm',
  dependencies = 'nvzone/volt',
  lazy = false,
  config = function()
    require('floaterm').setup {
      mappings = {
        term = function(buf)
          vim.keymap.set({ 'n', 't' }, '<C-p>', function()
            require('floaterm.api').cycle_term_bufs 'prev'
          end, { buffer = buf })
        end,
      },
    }
    vim.keymap.set('n', '<leader>tt', '<Cmd>:FloatermToggle<Cr>', { desc = 'Open terminals' })
  end,
  cmd = 'FloatermToggle',
}
