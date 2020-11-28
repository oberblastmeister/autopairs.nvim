local vim = vim
local api = vim.api
local utils = require("autopairs/utils")

local M = {}

--- maps a key to a lua function call
--- For example: mapper("<CR>", on_backspace()). The function is automatically imported from autopairs
local function mapper(key, function_call)
  vim.cmd(string.format("inoremap <buffer> %s <cmd>lua require'autopairs'.%s<CR>", key, function_call))
end

local function generate_pair_fn_str(pair, fn_ident_str)
  return string.format([====[%s([[%s]])]====], fn_ident_str, pair)
end

function M.create()
  for open_pair, close_pair in pairs(utils.pair_table) do
    if open_pair == close_pair then
      mapper(open_pair, generate_pair_fn_str(open_pair, "on_both_pair"))
    else
      mapper(open_pair, generate_pair_fn_str(open_pair, "on_open_pair"))
      mapper(close_pair, generate_pair_fn_str(close_pair, "on_close_pair"))
    end
  end
  mapper("<Space>", "on_space()")
  mapper("<CR>", "on_enter()")
  mapper("<BS>", "on_backspace()")
end

return M
