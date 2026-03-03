local M = {}

--- Presents a picker to select a .slnx file from a list of files
--- @param files string[] List of .slnx file paths
--- @param callback function Function to call with the selected file path
function M.pick_slnx(files, callback)
  if #files == 1 then
    callback(files[1])
    return
  end

  require('snacks').picker {
    title = 'Select .slnx file',
    items = files,
    format = function(item)
      return item
    end,
    confirm = function(item)
      callback(item)
    end,
  }
end

return M
