local core = require 'highlight-whitespace.core'
local utils = require 'highlight-whitespace.utils'
local api = vim.api
local M = {}


function M.setup(cfg)
  core.cfg = vim.tbl_extend("keep", cfg or {}, utils.default)
  utils.check_deprecated(core.cfg)
  if not utils.check_colors(core.cfg.palette) then
    core.cfg.palette = utils.default.palette
    vim.notify(' Default palette is loaded instead',
      vim.log.levels.WARN, { title = 'highlight-whitespace', })
  end

  vim.tbl_map(function(ft)
    ft[core.cfg.tws] = ft.tws
    ft.tws = nil
  end, core.cfg.palette)

  local aug_hws = api.nvim_create_augroup('HighlightWS', {})
  api.nvim_create_autocmd(
    { 'BufWinEnter', 'WinEnter', 'TextChanged', 'CompleteDone' }, {
      callback = core.match_uws,
      group = aug_hws,
    })

  api.nvim_create_autocmd(
    'WinLeave', {
      callback = core.clear_uws_match,
      group = aug_hws,
    })

  api.nvim_create_autocmd(
    { 'InsertEnter', 'CursorMovedI' }, {
      callback = core.no_match_cl,
      group = aug_hws,
    })

  api.nvim_create_autocmd(
    'InsertLeave', {
      callback = core.clear_no_match_cl,
      group = aug_hws,
    })

  api.nvim_create_autocmd(
    'QuitPre', {
      callback = core.prune_dicts,
      group = aug_hws,
    })

  M._set_up = true
end

return M
