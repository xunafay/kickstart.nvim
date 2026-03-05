local Snacks = require 'snacks'
local harpoon = require 'harpoon'

local M = {}

local finder = function(opts, ctx)
  local items = require('harpoon'):list().items or {}

  local output = {}

  local max = 0
  for k, _ in pairs(items) do
    if type(k) == 'number' and k > max then
      max = k
    end
  end

  for i = 1, max do
    local item = items[i] -- NOTE: may be nil (harpoon "empty slot")
    local value = item and item.value
    if type(value) == 'string' and value:match '%S' then
      local row = (item.context and item.context.row) or 1
      local col = (item.context and item.context.col) or 0

      output[#output + 1] = {
        idx = i, -- NOTE: keep harpoon slot index
        text = value,
        file = value,
        pos = { row, col },
      }
    end
  end

  return output
end

function M.open()
  return Snacks.picker.pick {
    source = 'harpoon',
  }
end

function M.setup()
  Snacks.picker.sources.harpoon = {
    finder = finder,
    preview = function(ctx)
      if Snacks.picker.util.path(ctx.item) then
        return Snacks.picker.preview.file(ctx)
      else
        return Snacks.picker.preview.none(ctx)
      end
    end,
    confirm = 'jump',
    actions = {
      remove = function(picker, item)
        if not item then
          vim.notify('No item selected', vim.log.levels.WARN)
          return
        end

        local key = item.file or item._path
        if key then
          -- NOTE: annoyingly harpoon doesn't support removing by file path so we have to reconstruct the list item to remove it
          local list = harpoon:list()
          local item = list.config.create_list_item(list.config, item.file)
          list:remove(item)
          if #list.items == 0 then
            picker:close()
          else
            picker:refresh()
          end
        end
      end,
    },
    win = {
      input = {
        keys = {
          ['<c-x>'] = { 'remove', mode = { 'n', 'i' } },
        },
      },
      list = {
        keys = {
          ['<c-x>'] = 'remove',
          ['dd'] = 'remove',
        },
      },
    },
  }
end

return M
