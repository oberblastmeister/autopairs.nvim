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

--- takes only the open pair and checks if it is surrounded by the close pair
function M.is_surrounded_by(open_pair, line)
  local close_pair = M.pair_table[open_pair]
  return M.get_char_from_cursor(-1, line) == open_pair and
    M.get_char_from_cursor(0, line) == close_pair
end

--- checks if the cursor is surrounded by any pairs defined in pair_table
--- returns bool and what is was surrounded by
function M.is_surrounded_by_any(line)
  for open_pair, _ in pairs(M.pair_table) do
    if M.is_surrounded_by(open_pair, line) == true then
      return true, open_pair
    end
  end
end

--- returns 1 based index
function M.col()
  -- must add one because win get cursor return (1, 0) based index
  return api.nvim_win_get_cursor(0)[2] + 1
end

--- one based index
function M.linenr()
  return api.nvim_win_get_cursor(0)[1]
end

--- gets the char before the cursor
function M.get_char_before()
  local line = api.nvim_get_current_line()
  local idx =  M.col() + 1
  return line:sub(idx, idx)
end

--- gets the char with distance from the cursor.
--- if the cursor is the pipe symbol in insert mode,
--- '|' means that if distance is zero, ' to the
--- right of the cursor is the result
function M.get_char_from_cursor(distance, line)
  local idx = M.col() + distance
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

function M.replace_termcodes(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

return M
