return {
  'zbirenbaum/copilot.lua',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      panel = {
        auto_refresh = true,
        enabled = true,
      },
      suggestions = {
        auto_trigger = true,
        enabled = true,
      },
      filetypes = {
        ['.'] = true,
      },
    }
  end,
}
