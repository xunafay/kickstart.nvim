require 'solution.solution'
require 'tree.node'
local node_module = require 'tree.node'
local PROJECT_TYPES = require('solution').PROJECT_TYPES
local NodeType = node_module.NodeType
local TreeNode = node_module.TreeNode

local M = {}

---@param solution Solution
---@return TreeNode
function M.build_tree(solution)
  -- Create root solution node
  local path = vim.fn.fnamemodify(solution.path, ':t')
  local root = TreeNode:new(NodeType.SOLUTION, path, solution.path)

  -- Map nodes in solution to TreeNodes
  -- Expand solution folders by default
  local function add_solution_node(node, parent)
    local node_type = NodeType.PROJECT
    if node.kind == 'directory' then
      node_type = NodeType.FOLDER
    end
    local tree_node = TreeNode:new(node_type, node.name, node.path, nil)
    parent:add_child(tree_node)

    if node.kind == 'directory' then
      tree_node.expanded = true
      for _, child in ipairs(node.children) do
        add_solution_node(child, tree_node)
      end
    end

    M.populate_project_files(tree_node)
  end

  for _, project in ipairs(solution.tree) do
    add_solution_node(project, root)
  end

  -- Expand the root node and solution folders by default
  root.expanded = true

  return root
end

---@param project_node TreeNode
function M.populate_project_files(project_node)
  if not project_node.path then
    return
  end

  -- only all NodeType.PROJECT nodes to populate file tree
  if project_node.type ~= NodeType.PROJECT then
    return
  end

  local project_dir = vim.fn.fnamemodify(project_node.path, ':p:h')
  M.add_directory_contents(project_node, project_dir)
end

---@param node TreeNode
function M.nest_code_behind_files(node)
  if not node.children or #node.children == 0 then
    return
  end

  for _, child in ipairs(node.children) do
    --- Check if type is FILE
    if child.type ~= NodeType.FILE then
      -- Only process files, skip directories and other types
      goto continue
    end

    -- Check if child was already removed
    if not child then
      goto continue
    end

    local base_name = nil
    -- Handle special case appsettings.X.json files
    if child.name:match '^appsettings%.' and child.name ~= 'appsettings.json' then
      base_name = 'appsettings.json'
    end

    --- split filename on period
    if not base_name then
      local parts = vim.split(child.name, '%.')
      if #parts < 2 then
        -- code behind files extend a file with an additional extension
        -- ie: MyPage.razor and MyPage.razor.cs
        -- so we only nest if there are at least 3 parts
        goto continue
      end

      base_name = table.concat(parts, '.', 1, #parts - 1)
    end

    -- search for node that matches the base name and is not the same as the current node
    local code_behind_node = nil
    for _, sibling in ipairs(node.children) do
      if sibling.name == base_name and sibling ~= child then
        code_behind_node = sibling
        break
      end
    end

    if not code_behind_node then
      -- no matching code behind file found, continue to next child
      goto continue
    end

    -- If we found a code behind file, nest it under the main file
    if code_behind_node.type ~= NodeType.FILE then
      goto continue
    end

    local parent_node = child.parent

    if parent_node ~= nil then
      parent_node:remove_child(child)
    end

    code_behind_node:add_child(child)

    ::continue::
  end
end

---@param parent_node TreeNode
---@param dir_path string
function M.add_directory_contents(parent_node, dir_path)
  -- Check if directory exists and is readable
  local stat = vim.loop.fs_stat(dir_path)
  if not stat or stat.type ~= 'directory' then
    return
  end

  -- Get directory contents
  local handle = vim.loop.fs_scandir(dir_path)
  if not handle then
    return
  end

  local entries = {}

  -- Collect all entries
  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end

    -- Skip hidden files and common ignore patterns
    if
      not name:match '^%.'
      and not name:match '%.sln$'
      and not name:match '%.csproj$'
      and name ~= 'bin'
      and name ~= 'obj'
      and name ~= 'node_modules'
      and name ~= '.vs'
      and name ~= '.vscode'
    then
      table.insert(entries, { name = name, type = type })
    end
  end

  -- Sort entries: directories first, then files, both alphabetically
  table.sort(entries, function(a, b)
    if a.type == b.type then
      return a.name < b.name
    end
    -- Directories come before files
    return a.type == 'directory'
  end)

  -- Create nodes for each entry
  for _, entry in ipairs(entries) do
    local full_path = dir_path .. '/' .. entry.name
    local node_type = NodeType.FILE

    if entry.type == 'directory' then
      node_type = NodeType.FOLDER
    end

    local child_node = TreeNode:new(node_type, entry.name, full_path)
    parent_node:add_child(child_node)

    -- Recursively add contents for directories
    if entry.type == 'directory' then
      M.add_directory_contents(child_node, full_path)
    end
  end

  -- Code behind nesting
  M.nest_code_behind_files(parent_node)
end

return M
