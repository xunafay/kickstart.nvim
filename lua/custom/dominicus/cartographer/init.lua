local M = {}
local lector = require 'custom.dominicus.lector'

-- Internal State
M.state = {
  slnx_path = nil,
  project_paths = {}, -- Flat list of absolute paths to project directories
  solution_tree = nil, -- The full Solution object from your parser
  solution = nil,
}

function M.open_dotnet(opts)
  opts = opts or {}
  opts.source = 'dotnet_explorer'
  opts.slnx = M.state.slnx_path
  return Snacks.picker.pick(opts)
end

--- Transforms the parser tree into flat items for Snacks.picker
--- @param nodes table[] The tree nodes from your parser
--- @param parent_path string Used to create a unique 'virtual path' for the tree logic
--- @param items table The list we are accumulating
local function transform_tree_to_items(nodes, parent_path, items)
  for _, node in ipairs(nodes) do
    -- Create a unique virtual path for tree nesting logic
    local virtual_path = parent_path == '' and node.name or (parent_path .. '/' .. node.name)

    table.insert(items, {
      text = node.name,
      -- Important: Snacks tree logic uses the 'file' field to determine hierarchy levels
      file = virtual_path,
      -- Store the actual physical path for projects
      project_path = node.kind == 'project' and node.path or nil,
      is_dir = node.kind == 'directory',
      kind = node.kind,
    })

    if node.kind == 'directory' and node.children then
      transform_tree_to_items(node.children, virtual_path, items)
    end
  end
end

--- Recursive helper to extract all project paths from your Solution tree
--- @param nodes table[] Your parser's tree nodes
--- @param paths table Accretive table of paths
local function collect_project_paths(nodes, paths)
  for _, node in ipairs(nodes) do
    if node.kind == 'project' and node.path then
      table.insert(paths, node.path)
    elseif node.kind == 'directory' and node.children then
      collect_project_paths(node.children, paths)
    end
  end
end

function M.load_solution(slnx_path)
  local solution = lector.parse_projects(slnx_path)
  if not solution then
    return
  end

  M.state.slnx_path = slnx_path
  M.state.solution_tree = solution

  -- Flatten the tree to get directories for the pickers
  M.state.project_paths = {}
  collect_project_paths(solution.tree, M.state.project_paths)

  vim.notify('Solution Loaded: ' .. vim.fn.fnamemodify(slnx_path, ':t'), vim.log.levels.INFO)

  -- TODO: Trigger Roslyn to target this solution specifically
  -- Most roslyn.nvim setups look for a global or buffer-local sln path
  -- vim.g.roslyn_nvim_selected_solution = slnx_path

  -- Automatically open the Solution Explorer
  M.open_solution_explorer()
end

function M.open_solution_explorer()
  if not M.state.solution then
    return vim.notify('No solution loaded.', vim.log.levels.WARN)
  end

  local items = {}
  transform_tree_to_items(M.state.solution.tree, '', items)

  return Snacks.picker {
    title = 'Solution Explorer',
    items = items,
    -- We define the layout manually to fix the "no root box" error
    layout = {
      preview = false, -- We don't need a code preview for a solution tree
      layout = {
        position = 'right',
        width = 35,
        box = 'vertical',
        { win = 'list', border = 'none', title = '{title}', title_pos = 'center' },
      },
    },
    format = 'file',
    tree = true,
    finder = function()
      return items
    end,
    win = {
      list = {
        keys = {
          ['<cr>'] = 'confirm',
          ['o'] = 'confirm',
          ['<2-LeftMouse>'] = 'confirm',
        },
      },
    },
    actions = {
      confirm = function(picker, item)
        if item.kind == 'project' then
          -- Instead of opening a directory, we open a scoped file picker for that project
          picker:close()
          M.project_files(item.project_path, item.text)
        else
          -- It's a virtual folder, toggle the expansion
          picker:explorer_toggle()
        end
      end,
    },
  }
end

--- Scoped Picker for a specific project
function M.project_files(path, name)
  Snacks.picker.files {
    title = 'Project: ' .. name,
    dirs = { path },
    hidden = true,
  }
end

function M.pick_solution()
  Snacks.picker.files {
    title = 'Select Solution',
    finder = 'files',
    args = { '--glob', '*.slnx' },
    actions = {
      confirm = function(picker, item)
        picker:close()
        M.state.slnx_path = item.file
        M.state.solution = lector.parse_projects(item.file)

        if M.state.solution then
          -- Pass the solution to roslyn.nvim if needed
          vim.g.roslyn_nvim_selected_solution = item.file
          M.open_solution_explorer()
        end
      end,
    },
  }
end

function M.solution_files()
  if #M.state.project_paths == 0 then
    return M.pick_solution()
  end

  Snacks.picker.files {
    title = 'Files: ' .. vim.fn.fnamemodify(M.state.slnx_path, ':t'),
    dirs = M.state.project_paths,
  }
end

function M.solution_grep()
  if not M.state.solution then
    return M.pick_solution()
  end

  local paths = {}
  local function collect(nodes)
    for _, n in ipairs(nodes) do
      if n.kind == 'project' then
        table.insert(paths, n.path)
      elseif n.kind == 'directory' then
        collect(n.children)
      end
    end
  end
  collect(M.state.solution.tree)

  Snacks.picker.grep {
    title = 'Grep Solution',
    dirs = paths,
  }
end

Snacks.picker.actions.solution_files = function()
  M.solution_files()
end
Snacks.picker.actions.solution_grep = function()
  M.solution_grep()
end

return M
