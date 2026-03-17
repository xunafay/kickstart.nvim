return {
  enable = true,
  lazy = false,
  'seblyng/roslyn.nvim',
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    filewatching = 'auto',
    choose_target = function(targets)
      local slnx = {}

      for _, file in ipairs(targets) do
        if type(file) == 'string' and file:match '%.slnx$' then
          table.insert(slnx, file)
        end
      end

      if #slnx == 1 then
        return slnx[1]
      end

      return nil
    end,
    lock_target = true,
  },
  dependencies = {
    'j-hui/fidget.nvim',
  },
  keys = {
    {
      '<leader>lr',
      function()
        vim.cmd 'Roslyn restart'
        vim.cmd 'Roslyn start'
      end,
      desc = 'Restart Roslyn LSP',
    },
  },
  config = function()
    local handles = {}

    vim.lsp.config('roslyn', {
      on_attach = function(client)
        vim.notify('Roslyn LSP attached', vim.log.levels.INFO)
      end,
      settings = {
        ['csharp|inlay_hints'] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
        },
        ['csharp|code_lens'] = {
          dotnet_enable_references_code_lens = true,
          dotnet_enable_tests_code_lens = true,
        },
        ['csharp|background_analysis'] = {
          dotnet_analyzer_diagnostics_scope = 'openFiles',
          dotnet_compiler_diagnostics_scope = 'fullSolution',
        },
        ['csharp|completion'] = {
          dotnet_show_completion_items_from_unimported_namespaces = true,
          dotnet_show_name_completion_suggestions = true,
          dotnet_provide_regex_completions = true,
        },
        ['csharp|symbol_search'] = {
          dotnet_search_reference_assemblies = true,
        },
        ['csharp|formatting'] = {
          dotnet_organize_imports_on_format = false,
        },
      },
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'RoslynRestoreProgress',
      callback = function(ev)
        local token = ev.data.params[1]
        local handle = handles[token]
        if handle then
          handle:report {
            title = ev.data.params[2].state,
            message = ev.data.params[2].message,
          }
        else
          handles[token] = require('fidget.progress').handle.create {
            title = ev.data.params[2].state,
            message = ev.data.params[2].message,
            lsp_client = {
              name = 'roslyn',
            },
          }
        end
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'RoslynRestoreResult',
      callback = function(ev)
        local handle = handles[ev.data.token]
        handles[ev.data.token] = nil

        if handle then
          handle.message = ev.data.err and ev.data.err.message or 'Restore completed'
          handle:finish()
        end
      end,
    })
  end,
}
