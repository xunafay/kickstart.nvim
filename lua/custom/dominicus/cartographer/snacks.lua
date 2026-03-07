local Snacks = require 'snacks'

local M = {
  state = {
    slnx_path = nil,
    tree = nil, ---@type snacks.picker.explorer.Tree
  },
}

function M.config(opts)
  opts = opts or {}
  opts.tree = true
  opts.watch = true
  opts.formatters = {
    file = { filename_only = true },
    severity = { pos = 'right' },
  }
  opts.matcher = { sort_empty = false, fuzzy = false }
  return opts
end

function M.pick_solution()
  Snacks.picker.files {
    title = 'Select Solution',
    finder = 'files',
    args = { '--glob', '*.slnx' },
    show_empty = false,
    auto_confirm = true,
    actions = {
      confirm = function(picker, item)
        picker:close()
        M.state.slnx_path = item.file
      end,
    },
  }
end

function M.finder(opts, ctx)
  local tree = require 'custom.dominicus.cartographer.tree'

  local items = {}

  local root = tree:add_virtual('', 'cartographer')

  local dir_a = tree:add_virtual(root.path, 'continent_a')
  tree:add_virtual(dir_a.path, 'region_a1')

  local dir_b = tree:add_virtual(root.path, 'continent_b')
  tree:add_virtual(dir_b.path, 'region_b1')

  tree:get(root.path, function(node)
    table.insert(items, node)
  end, { expand = false })

  return items
end

function M.setup()
  Snacks.picker.sources.cartographer = {
    title = 'Solution Explorer',
    tree = true,
    layout = {
      preset = 'sidebar',
      preview = false,
      width = 35,
    },
    finder = M.finder,
    actions = {
      confirm = function(picker, item)
        -- TODO: open file if it's a real file, or toggle expand if it's a virtual folder
      end,
    },
    keys = {
      win = {
        list = {
          ['<cr>'] = 'confirm',
          ['o'] = 'confirm',
          ['<2-LeftMouse>'] = 'confirm',
        },
      },
    },
  }
end

return M
