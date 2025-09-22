return {
  'Willem-J-an/adopure.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'sindrets/diffview.nvim', -- Optionally required to open PR in diffview
  },
  config = function()
    vim.g.adopure = {
      filter_my_pull_requests = true, -- Only load pull requests assigned to you
    }
    vim.keymap.set('n', '<leader>alc', '<Cmd>:AdoPure load context<Cr>', { desc = 'Load open pull requests; prompt user to pick one.' })
    vim.keymap.set('n', '<leader>alt', '<Cmd>:AdoPure load threads<Cr>', { desc = 'Fetch comment threads from Azure DevOps.' })
    vim.keymap.set('n', '<leader>aoq', '<Cmd>:AdoPure open quickfix<Cr>', { desc = 'Open comment threads in quickfix window.' })
    vim.keymap.set('n', '<leader>aot', '<Cmd>:AdoPure open thread_picker<Cr>', { desc = 'Open a Telescope picker to select a comment thread to view.' })
    vim.keymap.set('n', '<leader>aon', '<Cmd>:AdoPure open new_thread<Cr>', { desc = 'Create a new comment thread on the current selection.' })
    vim.keymap.set('n', '<leader>aoe', '<Cmd>:AdoPure open existing_thread<Cr>', { desc = 'Open a window with an existing comment thread.' })
    vim.keymap.set('n', '<leader>asc', '<Cmd>:AdoPure submit comment<Cr>', { desc = 'Submit a comment to the currently opened comment thread.' })
    vim.keymap.set('n', '<leader>asv', '<Cmd>:AdoPure submit vote<Cr>', { desc = 'Approve or decline the pull request.' })
    vim.keymap.set('n', '<leader>ast', '<Cmd>:AdoPure submit thread_status<Cr>', { desc = 'Submit a thread_status change; must be in existing_thread window' })
    vim.keymap.set(
      'n',
      '<leader>asd',
      '<Cmd>:AdoPure submit delete_comment<Cr>',
      { desc = 'Delete the comment under the cursor; must be in existing_thread window' }
    )
    vim.keymap.set(
      'n',
      '<leader>ase',
      '<Cmd>:AdoPure submit edit_comment<Cr>',
      { desc = 'Edit the comment under the cursor; must be in existing_thread window' }
    )
  end,
}
