local core = require "highlight-whitespace.core"
local wrap_fn = require "highlight-whitespace.wrap_fn"
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
  local create_autocmd = function(events, callback)
    api.nvim_create_autocmd(events, {
      callback = function(args)
        callback(args)
      end,
      group = aug_hws,
    })
  end

  local match_uws_events = { "TextChanged", "CompleteDone" }
  if core.cfg.clear_on_bufleave then
    create_autocmd("BufLeave", core.clear_uws_match)
    table.insert(match_uws_events, "BufEnter")
  end
  create_autocmd(match_uws_events, wrap_fn.match_uws)
  create_autocmd("BufWinEnter", wrap_fn.get_matches_from_cache)
  create_autocmd("BufHidden", wrap_fn.save_matches_to_cache_and_clear)
  create_autocmd({ "InsertEnter", "CursorMovedI" }, wrap_fn.no_match_cl)
  create_autocmd("InsertLeave", wrap_fn.clear_no_match_cl)
  create_autocmd("QuitPre", core.prune_dicts)
  M._set_up = true
end

return M
