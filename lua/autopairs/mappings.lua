local vim = vim
local api = vim.api
local utils = require("autopairs/utils")

local M = {}

local function generate_pair_fn_str(pair, fn_ident_str)
  return string.format([====[<cmd>lua require'autopairs'.%s([[%s]])<CR>]====], fn_ident_str, pair)
end

function M.create()
  for open_pair, close_pair in pairs(utils.pair_table) do
    if open_pair == close_pair then
      api.nvim_buf_set_keymap(0, 'i', open_pair, generate_pair_fn_str(open_pair, "on_both_pair"), {noremap = true})
    else
      api.nvim_buf_set_keymap(0, 'i', open_pair, generate_pair_fn_str(open_pair, "on_open_pair"), {noremap = true})
      api.nvim_buf_set_keymap(0, 'i', close_pair, generate_pair_fn_str(close_pair, "on_close_pair"), {noremap = true})
    end
  end

  api.nvim_buf_set_keymap(0, "i", "<Space>", "<cmd>lua require'autopairs'.on_space()<CR>", {noremap = true})
  api.nvim_buf_set_keymap(0, "i", "<CR>", "<cmd>lua require'autopairs'.on_enter()<CR>", {noremap = true})
  api.nvim_buf_set_keymap(0, "i", "<BS>", "<cmd>lua require'autopairs'.on_backspace()<CR>", {noremap = true})
end

return M
