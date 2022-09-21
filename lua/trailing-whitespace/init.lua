local tws = require'trailing-whitespace.core'
local api = vim.api
local M = {}


local aug_tws = api.nvim_create_augroup('TrailingWS' , {clear=true})

api.nvim_create_autocmd(
  { 'BufWinEnter', 'WinEnter', 'TextChanged' }, {
  callback = tws.match_tws,
  group = aug_tws,
})

api.nvim_create_autocmd(
  'WinLeave', {
  callback = tws.clear_tws_match,
  group = aug_tws,
})

api.nvim_create_autocmd(
  'InsertEnter', {
  callback = tws.no_match_cl,
  group = aug_tws,
})

api.nvim_create_autocmd(
  'InsertLeave', {
  callback = tws.clear_no_match_cl,
  group = aug_tws,
})


function M.setup (conf)
  conf = conf or {}

  tws.patterns = conf.patterns or { '\\s\\+$' }
  tws.palette = conf.palette or { markdown = 'RosyBrown' }
  tws.palette.default = conf.default_color or 'PaleVioletRed'
  M._set_up = true
end


return M
