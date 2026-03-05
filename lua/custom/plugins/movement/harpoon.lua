return {
  'ThePrimeagen/harpoon',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  branch = 'harpoon2',
  keys = {
    {
      '<leader>hpa',
      function()
        require('harpoon'):list():add()
      end,
      desc = 'Add file to harpoon',
    },
    {
      '<leader>hpl',
      function()
        require('custom.harpoon.snacks').open()
      end,
      desc = 'Open harpoon picker',
    },
    {
      '<leader>hpb',
      function()
        require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())
      end,
      desc = 'Toggle harpoon quick menu',
    },
    {
      '<leader>hpd',
      function()
        require('harpoon'):list():remove()
      end,
      desc = 'Remove file from harpoon',
    },
    {
      '<leader>hpp',
      function()
        require('harpoon'):list():prev()
      end,
      desc = 'Go to previous harpoon file',
    },
    {
      '<leader>hpn',
      function()
        require('harpoon'):list():next()
      end,
      desc = 'Go to next harpoon file',
    },
  },
  config = function()
    require('harpoon'):setup()
    require('custom.harpoon.snacks').setup()
  end,
}
