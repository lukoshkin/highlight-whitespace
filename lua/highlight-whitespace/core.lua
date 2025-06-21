--- Variable namings:
--- cl - current line
--- (u|h|t)ws - (unwanted|highlight|trailing) whitespace

local utils = require "highlight-whitespace.core_utils"
local api = vim.api
local fn = vim.fn

local M = {}
M.ns_id = api.nvim_create_namespace "HWS"
M.win_match_opts = {}
M.win_cl_match = {}

local function scan_and_highlight(group_name, pattern, opts)
  --- vim.fn.line uses 1-based indexing, but we need 0-based for
  --- nvim_buf_set_extmark and for vim.regex:match_line
  local start_line = opts and opts.start_line or fn.line "w0"
  local end_line = opts and opts.end_line or fn.line "w$"
  local re = vim.regex(pattern)

  for line_idx = start_line, end_line do
    local start_col = 0
    while start_col do
      local ok, match_start, match_end = pcall(function()
        return re:match_line(0, line_idx - 1, start_col)
      end)
      if not ok or match_start == nil then
        break
      end

      vim.api.nvim_buf_set_extmark(0, M.ns_id, line_idx - 1, match_start, {
        end_col = match_end,
        hl_group = group_name,
        priority = opts and opts.priority or 10,
      })
      --- Move to the end of the current match
      start_col = match_end + 1
    end
  end

  return true
end

function M.match_uws()
  if utils.is_untargetable() then
    return
  end

  local ft = api.nvim_get_option_value("filetype", { buf = 0 })
  local content_id = utils.win_content_alias(ft)
  local win_match_opts = M.win_match_opts[content_id]
  if win_match_opts then
    local range = win_match_opts.range
    if range and fn.line "w0" == range[1] and fn.line "w$" == range[2] then
      return
    end
  end

  win_match_opts = win_match_opts or {}
  api.nvim_buf_clear_namespace(0, M.ns_id, 0, -1)
  win_match_opts.range = { vim.fn.line "w0", vim.fn.line "w$" }
  M.win_match_opts[content_id] = win_match_opts

  local uws_pat_list = M.cfg.palette[ft] or M.cfg.palette["other"]
  for pat, color in pairs(uws_pat_list) do
    local group_name = "HWS_" .. color:gsub("#", "")
    api.nvim_set_hl(M.ns_id, group_name, { bg = color })
    api.nvim_win_set_hl_ns(0, M.ns_id)
    -- scan_and_highlight(group_name, pat)
  end
end

function M.unmatch_line_after_cursor()
  --- Remove '$' (otherwise, won't work) and specify that "uncoloring"
  --- applies only to the current line ('\%.l'), up to the cursor ('\%.c'),
  --- and only to trailing whitespace (`main_pat` .. '\(\s*\S\)\@!').
  local cl_tws_pat = M.cfg.tws:gsub("%$", "")
    .. "\\%.l\\%.c"
    .. "\\(\\s*\\S\\)\\@!"
  local wid = api.nvim_get_current_win()
  --- Default priority is 10, we set just a bit higher.
  M.win_cl_match[wid] = fn.matchadd("CL_TWS", cl_tws_pat, 11)
  --- fg color should have a not NONE value.
  --- Otherwise, it will not work.
  api.nvim_set_hl(M.ns_id, "CL_TWS", { fg = "#ffffff" })
  api.nvim_win_set_hl_ns(0, M.ns_id)
end

return M
