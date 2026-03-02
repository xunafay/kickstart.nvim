return {
  {
    'wojciechkepka/vim-github-dark',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      --require('vim-github-dark').setup {
      --  styles = {
      --    comments = { italic = false }, -- Disable italics in comments
      --  },
      --}

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'ghdark'
    end,
  },
}
