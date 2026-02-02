-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '<C-b>', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = function()
    local default_opts = {
      auto_clean_after_session_restore = false,
      filesystem = {
        -- renderers = {
        --   directory = {
        --     {
        --       'chipSoftShorten',
        --       render = function(config, node, state)
        --         -- Shorten ChipSoft.Ezis.<Module> to Ezis.<Module>
        --         -- Shorten ChipSoft.Services.<Module> to Serv.<Module>
        --         -- Shorten ChipSoft.Publics.<Module> to Pub.<Module>
        --
        --         local path = node.path
        --         local shortened_path = path
        --         shortened_path = shortened_path:gsub('ChipSoft%.Ezis%.', 'Ezis%.')
        --         shortened_path = shortened_path:gsub('ChipSoft%.Services%.', 'Serv%.')
        --         shortened_path = shortened_path:gsub('ChipSoft%.Publics%.', 'Pub%.')
        --         node.path = shortened_path
        --         require('neo-tree.ui.renderer').renderers.directory[1].render(config, node, state)
        --         node.path = path -- restore original path
        --       end,
        --     },
        --   },
        -- },
        window = {
          mappings = {
            ['<C-b>'] = 'close_window',
          },
        },
        filtered_items = {
          visible = false,
          hide_dotfiles = true,
          hide_gitignored = true,
        },
      },
    }
    local project_config_path = vim.fn.getcwd() .. '\\.neotree.lua'
    if vim.fn.filereadable(project_config_path) == 1 then
      print('Loading NeoTree project configuration from ' .. project_config_path)
      local project_config = dofile(project_config_path)
      -- Merge project_config into default_opts (simple shallow merge)
      for k, v in pairs(project_config) do
        default_opts[k] = v
      end
    end
    return default_opts
  end,
}
