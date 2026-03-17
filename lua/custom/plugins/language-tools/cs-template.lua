return {
  dir = vim.fn.stdpath 'config',
  name = 'cs-template',
  lazy = false,
  config = function()
    local function find_csproj_dir(path)
      local dir = vim.fs.dirname(path)
      while dir and dir ~= vim.fs.dirname(dir) do
        for name, type in vim.fs.dir(dir) do
          if type == 'file' and name:match '%.csproj$' then
            return dir
          end
        end
        dir = vim.fs.dirname(dir)
      end
      return nil
    end

    local function path_to_namespace(file_path, root)
      local relative = file_path:sub(#root + 2)
      local dir = vim.fs.dirname(relative)

      local project_name
      for name, type in vim.fs.dir(root) do
        if type == 'file' and name:match '%.csproj$' then
          project_name = name:gsub('%.csproj$', '')
          break
        end
      end
      project_name = project_name or vim.fs.basename(root)

      if dir == '.' or dir == '' then
        return project_name
      end

      return project_name .. '.' .. dir:gsub('[/\\]', '.')
    end

    local function apply_template(args)
      local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
      local content = table.concat(lines, '')

      if content:match '^%s*$' == nil then
        return
      end

      local file_path = vim.api.nvim_buf_get_name(args.buf)
      local file_name = vim.fn.fnamemodify(file_path, ':t:r')

      local csproj_dir = find_csproj_dir(file_path)
      local namespace
      if csproj_dir then
        namespace = path_to_namespace(file_path, csproj_dir)
      else
        namespace = vim.fn.fnamemodify(file_path, ':h:t')
      end

      local kind = file_name:match '^I%u' and 'interface' or 'class'

      -- NOTE: Do I want to use a more advanced template system?
      local template = {
        'namespace ' .. namespace .. ';',
        '',
        'internal ' .. kind .. ' ' .. file_name,
        '{',
        '}',
      }

      vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, template)
      vim.api.nvim_win_set_cursor(0, { 4, 0 })
    end

    -- BufNewFile: for files created via :e
    vim.api.nvim_create_autocmd('BufNewFile', {
      pattern = '*.cs',
      callback = apply_template,
    })

    -- BufReadPost: for files created on disk (e.g. via Snacks explorer)
    vim.api.nvim_create_autocmd('BufReadPost', {
      pattern = '*.cs',
      callback = apply_template,
    })
  end,
}
