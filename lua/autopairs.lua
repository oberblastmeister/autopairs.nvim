local vim = vim
local api = vim.api
local utils = require("autopairs/utils")

local M = {}

do
  --- cache the current line
  -- local current_line

  -- local function get_current_line()
  --   if current_line == nil then
  --     current_line = api.nvim_get_current_line()
  --   end
  --   return current_line
  -- end

  --- inserts a closing pair from an opening pair
  function M.on_open_pair(open_pair)
    local close_pair = utils.pair_table[open_pair]
    local input = string.format("%s%s", open_pair, close_pair)
    api.nvim_feedkeys(input, 'in', false)
    api.nvim_input("<Left>")
  end

  function M.on_close_pair(close_pair)
    if utils.get_char_cursor() == close_pair then
    -- if utils.get_char_before() == close_pair then
      api.nvim_input("<Right>")
    else
      api.nvim_feedkeys(close_pair, 'in', false)
    end
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

function M.create_buffer_keymaps()
  for open_pair, close_pair in pairs(utils.pair_table) do
    map_open_pair(open_pair)
    map_close_pair(close_pair)
  end
end

return M
