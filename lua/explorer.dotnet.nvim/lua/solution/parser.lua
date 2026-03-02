-- require("solution.solution")
local Solution = require('solution.solution').Solution
local SolutionHeader = require('solution.solution_header').SolutionHeader
local M = {}

local project_types = require 'solution.project_types'

--- Parses a solution file and returns a Solution object
---@param filepath string The absolute path to the solution file
---@return Solution
function M.parse_solution(filepath)
  local file = io.open(filepath, 'r')
  if not file then
    error('Could not open solution file: ' .. filepath)
  end

  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end

  file:close()

  -- local header = M._parse_solution_header(lines)
  local solution = Solution.new(filepath, nil)
  local projects = M._parse_projects(lines, solution)

  --local global_section = M._parse_global(lines)
  --local nested_project_section = M._parse_global_section(global_section, 'NestedProjects')
  --local nested_projects = M._parse_nested_projects(nested_project_section)

  --solution.nested_projects = nested_projects

  return solution
end

--- Parses the solution header from the given lines.
---@param lines string[] The lines of the solution file.
---@return SolutionHeader
function M._parse_solution_header(lines)
  local header = SolutionHeader.new(nil, nil, nil)
  for _, line in ipairs(lines) do
    local min_vs_version = line:match 'MinimumVisualStudioVersion = (.+)'
    if min_vs_version and not header.minimum_visual_studio_version then
      -- Check MinimumVisualStudioVersion first because it can match ambiguously with VisualStudioVersion
      header.minimum_visual_studio_version = min_vs_version
    end

    local vs_version = line:match 'VisualStudioVersion = (.+)'
    if vs_version and not header.visual_studio_version then
      header.visual_studio_version = vs_version
    end

    local format_version = line:match 'Microsoft Visual Studio Solution File, Format Version (.+)'
    if format_version and not header.file_version then
      header.file_version = format_version
    end

    if header.visual_studio_version and header.file_version and header.minimum_visual_studio_version then
      break
    end
  end

  return header
end

--- Parses project information from solution file lines
---@param lines string[] The lines of the solution file
---@param solution Solution The Solution object to which the projects will be added (not used in this implementation but can be useful for future extensions)
function M._parse_projects(lines, solution)
  local folder_start_pattern = '<Folder Name="([%a/]+)" ?%/?>'
  local folder_end_pattern = '</Folder>'
  local project_pattern = '<Project Path="(.*%/(.*).csproj)"'

  local current_folder = nil

  for _, line in ipairs(lines) do
    local folder_name = line:match(folder_start_pattern)
    if folder_name then
      current_folder = folder_name
    elseif line:match(folder_end_pattern) then
      current_folder = nil
    else
      local project_path, project_name = line:match(project_pattern)
      if project_path and project_name then
        local project = {
          name = project_name,
          path = project_path,
          kind = 'project',
        }
        solution:add_project(project, current_folder)
      end
    end
  end
end

--- Parses the NestedProjects section of a solution file
---@param lines string[] The lines of the solution file
---@return table<string, string> A map of project GUIDs to their parent GUIDs
function M._parse_nested_projects(lines)
  local nested_projects = {}

  for _, line in ipairs(lines) do
    -- Match the NestedProjects line pattern:
    -- {ChildGUID} = {ParentGUID}
    local child_guid, parent_guid = string.match(line, '^[ \t]*(%b{})%s*=%s*(%b{})$')
    if parent_guid and child_guid then
      parent_guid = parent_guid:sub(2, -2) -- Remove first and last character (the braces)
      child_guid = child_guid:sub(2, -2)
      nested_projects[child_guid] = parent_guid
    end
  end

  return nested_projects
end

--- Parses a specific GlobalSection from the solution file
---@param lines string[] The lines of the solution file
---@param section_name string The name of the section to parse (e.g., "NestedProjects")
---@return string[] The lines of the specified section, trimmed of leading/trailing whitespace
function M._parse_global_section(lines, section_name)
  local section = {}
  local in_section = false
  local section_start_pattern = '^[ \t]*GlobalSection%(' .. section_name .. '%)'
  local section_end_pattern = '^[ \t]*EndGlobalSection'

  -- Find the section start
  for _, line in ipairs(lines) do
    if not in_section then
      if string.match(line, section_start_pattern) then
        in_section = true
      end
    else
      if string.match(line, section_end_pattern) then
        break -- End of the section
      else
        section[#section + 1] = line
      end
    end
  end
  return section
end

--- Parses Global..EndGlobal contents from the solution file
---@param lines string[] The lines of the solution file
---@return string[] The contents of the Global section, excluding the header and footer
function M._parse_global(lines)
  local global_section = {}
  local in_global = false

  for _, line in ipairs(lines) do
    if not in_global then
      if string.match(line, '^[ \t]*Global%s*$') then
        in_global = true
      end
    else
      if string.match(line, '^[ \t]*EndGlobal%s*$') then
        break -- End of the Global section
      else
        global_section[#global_section + 1] = line:match '^%s*(.-)%s*$' -- Trim whitespace
      end
    end
  end

  return global_section
end

return M
