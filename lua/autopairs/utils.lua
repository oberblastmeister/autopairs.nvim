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

--- tells if the open_pair is the same as the close pair
function M.is_same_pair(open_pair)
  return open_pair == M.pair_table[open_pair]
end

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

--- Return the different between the pairs. Negative means there are more closing pairs.
--- Positive means there are more opening pairs. 0 means the pairs are balanced
function M.line_is_closed(open_pair, line)
  if M.is_same_pair(open_pair) then
    return line_is_closed_same(open_pair, line)
  else
    return line_is_closed_different(open_pair, line)
  end
end

function line_is_closed_different(open_pair, line)
  local stack = 0
  for uchar in string.gmatch(line, "([%z\1-\127\194-\244][\128-\191]*)") do
    -- push to the stack
    if uchar == M.pair_table[open_pair] then
      -- pop off the stack
      stack = stack - 1
    elseif uchar == open_pair then
      stack = stack + 1
    end
  end
  return stack
end

--- when the open pair and close pair are the same like '"'
function line_is_closed_same(open_pair, line)
  local num = 0
  for uchar in string.gmatch(line, "([%z\1-\127\194-\244][\128-\191]*)") do

    if uchar == open_pair then
      num = num + 1
    end
  end
  return num % 2
end

return M
