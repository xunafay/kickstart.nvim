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
        local snacks = require 'snacks'
        snacks.picker.pick() {
          finder = function(opts, ctx)
            local output = {}
            for _, item in ipairs(require('harpoon'):list().items) do
              if item and item.value:match '%S' then
                table.insert(output, {
                  text = item.value,
                  file = item.value,
                  pos = { item.context.row, item.context.col },
                })
              end
            end
            return output
          end,
        }
        -- toggle_telescope(require('harpoon').list())
      end,
      desc = 'Open harpoon window',
    },
  },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    local harpoon_extensions = require 'harpoon.extensions'
    harpoon:extend(harpoon_extensions.builtins.highlight_current_file())

    vim.keymap.set('n', '<leader>hpn', function()
      harpoon:list():select(1)
    end, { desc = 'Go to harpoon 1' })
    vim.keymap.set('n', '<leader>hpe', function()
      harpoon:list():select(2)
    end, { desc = 'Go to harpoon 2' })
    vim.keymap.set('n', '<leader>hpo', function()
      harpoon:list():select(3)
    end, { desc = 'Go to harpoon 3' })
    vim.keymap.set('n', '<leader>hpi', function()
      harpoon:list():select(4)
    end, { desc = 'Go to harpoon 4' })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<leader>hpp', function()
      harpoon:list():prev()
    end, { desc = 'Go to previous harpoon file' })
    vim.keymap.set('n', '<leader>hpf', function()
      harpoon:list():next()
    end, { desc = 'Go to next harpoon file' })
  end,
}
