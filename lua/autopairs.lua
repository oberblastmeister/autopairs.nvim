local vim = vim
local api = vim.api
local utils = require("autopairs/utils")

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

function M.on_enter()
  local line = api.nvim_get_current_line()
  local is_surrounded, open_pair = utils.is_surrounded_by_any(line)
  if is_surrounded then
    local input = utils.replace_termcodes("<CR><CR><Esc>kk=2jjS")
    api.nvim_feedkeys(input, 'n', true)
  else
    api.nvim_feedkeys(utils.replace_termcodes("<CR>"), 'ni', false)
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

local function mapper(key, value)
  vim.cmd(string.format("inoremap <buffer> %s <cmd>%s<CR>", key, value))
end

local function generate_open_pair_fn_str(key)
  return string.format("lua require'autopairs'.on_open_pair(\"%s\")", key)
end

local function generate_close_pair_fn_str(key)
  return string.format("lua require'autopairs'.on_close_pair(\"%s\")", key)
end

local function map_open_pair(open_pair)
  mapper(open_pair, generate_open_pair_fn_str(open_pair))
end

local function map_close_pair(close_pair)
  mapper(close_pair, generate_close_pair_fn_str(close_pair))
end

local function map_enter()
  mapper("<CR>", "lua require'autopairs'.on_enter()")
end

local function map_space()
  mapper("<Space>", "lua require'autopairs'.on_space()")
end

local function map_backspace()
  mapper("<BS>", "lua require'autopairs'.on_backspace()")
end

local function create_buffer_keymaps()
  for open_pair, close_pair in pairs(utils.pair_table) do
    map_open_pair(open_pair)
    map_close_pair(close_pair)
  end
  map_enter()
  map_space()
  map_backspace()
end

function M.setup(config)
  create_buffer_keymaps()
end

return M
