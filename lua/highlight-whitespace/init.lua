local core = require "highlight-whitespace.core"
local utils = require "highlight-whitespace.utils"
local api = vim.api
local M = {}

function M.setup(cfg)
  core.cfg = vim.tbl_extend("keep", cfg or {}, utils.default)
  utils.check_deprecated(core.cfg)
  utils.check_config_conforms(core.cfg)
  utils.check_colors(core.cfg)

  vim.tbl_map(function(ft)
    ft[core.cfg.tws] = ft.tws
    ft.tws = nil
  end, core.cfg.palette)

  local aug_hws = api.nvim_create_augroup("HighlightWS", {})
  local match_uws_events = { "TextChanged", "CompleteDone" }
  if core.cfg.clear_on_bufleave then
    api.nvim_create_autocmd("BufLeave", {
      callback = function(args)
        core.clear_uws_match(args.buf)
      end,
      group = aug_hws,
    })
    table.insert(match_uws_events, "BufEnter")
  end
  api.nvim_create_autocmd(match_uws_events, {
    callback = core.match_uws,
  })
  api.nvim_create_autocmd("BufWinEnter", {
    callback = core.get_matches_from_cache,
    group = aug_hws,
  })
  api.nvim_create_autocmd("BufHidden", {
    callback = function(args)
      core.save_matches_to_cache_and_clear(args.buf)
    end,
    group = aug_hws,
  })
  api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, {
    callback = core.no_match_cl,
    group = aug_hws,
  })
  api.nvim_create_autocmd("InsertLeave", {
    callback = core.clear_no_match_cl,
    group = aug_hws,
  })
  api.nvim_create_autocmd("QuitPre", {
    callback = core.prune_dicts,
    group = aug_hws,
  })
  M._set_up = true
end

return M
