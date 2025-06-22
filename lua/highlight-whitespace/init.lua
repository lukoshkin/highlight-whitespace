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
    create_autocmd("BufLeave", function(args)
      api.nvim_buf_clear_namespace(args.buf, core.ns_id, 0, -1)
    end)
  end
  create_autocmd("InsertLeave", core.match_uws)
  create_autocmd({
    "InsertEnter",
    "CursorMovedI",
  }, core.unmatch_cl_tws_before_cursor)
  create_autocmd({
    "BufEnter",
    "CursorMoved",
    "TextChanged",
    "CompleteDone",
  }, core.match_uws)
  M._set_up = true
end

return M
