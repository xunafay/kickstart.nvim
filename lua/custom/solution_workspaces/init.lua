local M = {}

function M.setup()
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      vim.schedule(function()
        require('solution_workspaces.workspace').bootstrap()
      end)
    end,
  })

  vim.api.nvim_create_user_command('SolutionWorkspaceRebuild', function()
    require('solution_workspaces.workspace').rebuild()
  end, {})
end

return M
