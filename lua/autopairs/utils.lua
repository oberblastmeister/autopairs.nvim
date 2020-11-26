local vim = vim
local api = vim.api

local M = {}

--- the table of pairs to close
M.pair_table = {
  ["{"] = "}",
  ["["] = "]",
  ["("] = ")",
  ["<"] = ">",
  ["\""] = "\"",
  ["'"] = "'",
  ["`"] = "`",
}

function M.get_line()
  return api.nvim_get_current_line()
end

function M.col()
  return api.nvim_win_get_cursor(0)[2]
end

--- gets the char before the cursor
function M.get_char_before()
  local line = api.nvim_get_current_line()
  -- add one to convert from 0 based index to 1, add another 1 to get char before
  local idx =  M.col() + 1 + 1
  return line:sub(idx, idx)
end

function M.get_char_cursor()
  local line = api.nvim_get_current_line()
  local idx = M.col() + 1
  return line:sub(idx, idx)
end

function M.is_closed(line, open_pair)
  local stack = {}
  for uchar in string.gmatch(line, "([%z\1-\127\194-\244][\128-\191]*)") do
    if uchar == open_pair then
      -- push to the stack
      table.insert(stack, open_pair)
    elseif uchar == M.pair_table[open_pair] then
      -- pop off the stack
      if table.remove(stack) ~= open_pair then
        return false
      end
    end
  end
  return #stack == 0
end

return M
