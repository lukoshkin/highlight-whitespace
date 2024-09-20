local core = require "highlight-whitespace.core"
local utils = require "highlight-whitespace.init_utils"
local api = vim.api
local M = {}

function M.setup(cfg)
  cfg = cfg or {}
  core.cfg = utils.extend_palette_consciously(cfg)
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
        local ft = vim.bo.filetype
        local fts = vim.tbl_keys(core.cfg.palette)
        if
          (
            vim.tbl_contains(fts, ft)
            or not vim.tbl_isempty(core.cfg.palette.other)
          ) and utils.is_valid_buftype(args.buf)
        then
          callback(args)
        end
      end,
      group = aug_hws,
    })
  end

  if core.cfg.clear_on_bufleave then
    create_autocmd("BufLeave", core.cache_and_clear_uws_match)
  else
    create_autocmd("BufEnter", function()
      core.cache_and_clear_uws_match { target = "all_but_current" }
    end)
  end
  create_autocmd({ "TextChanged", "CompleteDone" }, core.match_uws)
  create_autocmd({ "BufEnter", "WinEnter" }, core.get_matches_from_cache)
  create_autocmd({ "InsertEnter", "CursorMovedI" }, core.no_match_cl)
  create_autocmd("InsertLeave", core.clear_no_match_cl)
  M._set_up = true
end

return M
