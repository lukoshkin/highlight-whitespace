--- Variable namings:
--- cl - current line
--- (u|h|t)ws - (unwanted|highlight|trailing) whitespace

local utils = require "highlight-whitespace.core_utils"
local api = vim.api
local fn = vim.fn

local M = {}
M.tws_hl_priority = 10
M.umatch_tws_hl_priority = 11
M.other_hls_priority = 12
M.inf_loop_max_cnt = 1e+6
M.ns_id = api.nvim_create_namespace "HWS"
M.win_match_opts = {}

local function scan_and_highlight(group_name, pattern, opts)
  local end_column = (opts and opts.end_column) and opts.end_column - 1 or nil
  --- NOTE: vim.fn.line uses 1-based indexing, but we need 0-based for
  --- nvim_buf_set_extmark and for vim.regex:match_line
  local start_line = opts and opts.start_line or fn.line "w0"
  local end_line = opts and opts.end_line or fn.line "w$"
  local re = vim.regex(pattern)

  for line_idx = start_line, end_line do
    local start_col = opts and opts.start_column or 0
    local loop_cnt = 0
    while loop_cnt < M.inf_loop_max_cnt do
      if end_column and start_col >= end_column then
        break
      end
      loop_cnt = loop_cnt + 1
      local ok, match_start, match_end = pcall(function()
        return re:match_line(0, line_idx - 1, start_col)
      end)
      if not ok or not match_start then
        break
      end
      --- NOTE: vim.regex:match_line returns start and end positions
      --- relative to the start of the search range passed
      match_end = match_end + start_col
      api.nvim_buf_set_extmark(
        0,
        M.ns_id,
        line_idx - 1,
        match_start + start_col,
        {
          end_col = end_column or match_end,
          hl_group = group_name,
          priority = opts and opts.priority or 10,
        }
      )
      --- Move to the end of the current match
      start_col = match_end + 1
    end
  end
end

function M.match_uws(args)
  if utils.is_untargetable_content() then
    return
  end

  local ft = api.nvim_get_option_value("filetype", { buf = 0 })
  local content_id = utils.win_content_alias(ft)
  local win_match_opts = M.win_match_opts[content_id]
  if win_match_opts and args.event == "CursorMoved" then
    local range = win_match_opts.range
    if range and fn.line "w0" == range[1] and fn.line "w$" == range[2] then
      return
    end
  end

  win_match_opts = win_match_opts or {}
  api.nvim_buf_clear_namespace(0, M.ns_id, 0, -1)
  win_match_opts.range = { fn.line "w0", fn.line "w$" }
  M.win_match_opts[content_id] = win_match_opts

  local uws_pat_list = M.cfg.palette[ft] or M.cfg.palette["other"]
  for pat, color in pairs(uws_pat_list) do
    local group_name = "HWS_" .. color:gsub("#", "")
    api.nvim_set_hl(M.ns_id, group_name, { bg = color })
    api.nvim_win_set_hl_ns(0, M.ns_id)
    scan_and_highlight(group_name, pat, {
      priority = M.cfg.tws == pat and M.tws_hl_priority
        or M.other_hls_priority,
    })
  end
end

function M.unmatch_cl_tws_before_cursor()
  --- Remove '$' (otherwise, won't hit) and specify override-pattern
  local cl_tws_pat = M.cfg.tws:gsub("%$", "")
  local normal_hl = api.nvim_get_hl(0, { name = "Normal" })
  local bg_color = normal_hl.bg and string.format("#%06x", normal_hl.bg)
    or "NONE"
  api.nvim_set_hl(M.ns_id, "CL_TWS", { bg = bg_color })
  api.nvim_win_set_hl_ns(0, M.ns_id)
  scan_and_highlight("CL_TWS", cl_tws_pat, {
    end_column = fn.col ".",
    start_line = fn.line ".",
    end_line = fn.line ".",
    priority = M.umatch_tws_hl_priority,
  })
end

return M
