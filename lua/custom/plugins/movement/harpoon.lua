return {
  'ThePrimeagen/harpoon',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  branch = 'harpoon2',
  config = function()
    local harpoon = require 'harpoon'

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    local harpoon_extensions = require 'harpoon.extensions'
    harpoon:extend(harpoon_extensions.builtins.highlight_current_file())

    -- basic telescope configuration
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
        })
        :find()
    end

    vim.keymap.set('n', '<leader>hpa', function()
      harpoon:list():add()
    end, { desc = 'Add file to harpoon' })

    vim.keymap.set('n', '<leader>hpl', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Open harpoon window' })

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
