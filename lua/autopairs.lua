local vim = vim
local api = vim.api
local utils = require("autopairs/utils")
local mappings = require("autopairs/mappings")

local M = {}

--- inserts a closing pair from an opening pair
function M.on_open_pair(open_pair)
  local close_pair = utils.pair_table[open_pair]
  local input = utils.replace_termcodes(string.format("%s%s<Left>", open_pair, close_pair))
  -- TODO: do undo points
  api.nvim_feedkeys(input, 'in', false)
end

function M.on_close_pair(close_pair)
  local line = api.nvim_get_current_line()
  if utils.get_char_from_cursor(0, line) == close_pair then
    api.nvim_feedkeys(utils.replace_termcodes("<Right>"), 'in', false)
  else
    -- vim.cmd [[redraw]]
    api.nvim_feedkeys(close_pair, 'in', false)
  end
end

function M.on_both_pair(both_pair)
  local line = api.nvim_get_current_line()
  if utils.get_char_from_cursor(0, line) == both_pair then
    api.nvim_feedkeys(utils.replace_termcodes("<Right>"), 'in', false)
  else
    api.nvim_feedkeys(both_pair, 'in', false)
  end
end

function M.on_enter()
  local line = api.nvim_get_current_line()
  local is_surrounded, open_pair = utils.is_surrounded_by_any(line)
  if is_surrounded then
    -- need escape to circumvent completion menu popup
    local input = utils.replace_termcodes("<Esc>a<CR><Right><Up><CR>")
    api.nvim_feedkeys(input, 'in', true)
  else
    api.nvim_feedkeys(utils.replace_termcodes("<CR>"), 'ni', true)
  end
end

function M.on_space()
  local line = api.nvim_get_current_line()
  local is_surrounded, open_pair = utils.is_surrounded_by_any(line)
  if is_surrounded then
    local input = utils.replace_termcodes("<Space><Space><Left>")
    api.nvim_feedkeys(input, "ni", true)
  else
    api.nvim_feedkeys(utils.replace_termcodes("<Space>"), "ni", true)
  end
end

function M.on_backspace()
  local line = api.nvim_get_current_line()
  local is_surrounded, open_pair = utils.is_surrounded_by_any(line)
  if is_surrounded then
    local input = utils.replace_termcodes("<BS><Del>")
    api.nvim_feedkeys(input, "ni", true)
  else
    api.nvim_feedkeys(utils.replace_termcodes("<BS>"), "ni", true)
  end
end

function M.setup(config)
  mappings.create()
end

return M
