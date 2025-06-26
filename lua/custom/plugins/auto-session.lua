return {
  'rmagatti/auto-session',
  lazy = false,
  config = function()
    local is_windors = vim.fn.has 'win64' == 1 or vim.fn.has 'win32' == 1
    local seperator = is_windors and '\\' or '/'
    require('auto-session').setup {
      root_dir = vim.fn.stdpath 'data' .. seperator .. 'sessions',
      git_use_branch_name = true,
      git_auto_restore_on_branch_change = true,
      lazy_support = true,
      continue_restore_on_error = false,
      -- pre_save_cmds = { 'Neotree close' },
      post_restore_cmds = { 'Neotree reveal' },
    }
  end,
}
