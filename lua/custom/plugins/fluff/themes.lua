local theme_cache = vim.fn.stdpath 'data' .. '/saved_theme'
local default_theme = 'catppuccin-mocha'

local function get_saved_theme()
  local f = io.open(theme_cache, 'r')
  if f then
    local saved = f:read('*all'):gsub('%s+', '')
    f:close()
    return (saved ~= '') and saved or default_theme
  end
  return default_theme
end

return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    -- TODO: I'd love to hue shift the base color on every instance so I can differentiate them a little better, or maybe I can pick a random color for some other highlight in the window
    opt = {},
    keys = {
      {
        '<leader>ut',
        function()
          require('snacks').picker.colorschemes()
        end,
        desc = 'Theme Picker',
      },
    },
    init = function()
      vim.schedule(function()
        local theme = get_saved_theme()
        pcall(vim.cmd.colorscheme, theme)
      end)
    end,
    config = function()
      -- vim.cmd.colorscheme(get_saved_theme())

      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function(args)
          local f = io.open(theme_cache, 'w')
          if f then
            f:write(args.match)
            f:close()
          end
        end,
      })
    end,
  },
  {
    'wojciechkepka/vim-github-dark',
    priority = 1000,
  },
}
