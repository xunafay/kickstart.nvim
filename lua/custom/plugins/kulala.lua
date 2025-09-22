return {
  'mistweaverco/kulala.nvim',
  keys = {
    { '<leader>drs', desc = 'Send request' },
    { '<leader>dra', desc = 'Send all requests' },
    { '<leader>drb', desc = 'Open scratchpad' },
  },
  ft = { 'http', 'rest' },
  opts = {
    global_keymaps = true,
    global_keymaps_prefix = '<leader>dr',
    kulala_keymaps_prefix = '',
    additional_curl_options = {
      '--negotiate',
    },
  },
}
