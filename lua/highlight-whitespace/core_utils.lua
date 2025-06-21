local M = {}
-- local fn = vim.fn
local api = vim.api

function M.is_untargetable(bnr, wid)
  --- Return true if either the buffer is not modifiable
  --- or the window where it is displayed is not normal.
  --- Otherwise, false is returned.
  return api.nvim_win_get_config(wid or 0).relative ~= ""
    or not api.nvim_get_option_value("modifiable", { buf = bnr or 0 })
end

function string:endswith(ending)
  self = tostring(self)
  ending = tostring(ending)
  return ending == "" or self:sub(-#ending) == ending
end

function M.win_content_alias(ft)
  local bname = api.nvim_buf_get_name(0)
  local wid = api.nvim_get_current_win()
  return table.concat({ bname, ft, wid }, "__")
end

function M.strip_wid(id, wid)
  wid = tostring(wid)
  return id:sub(1, #id - #wid - 2)
end

-- local function is_in_match_groups(gname, wid)
--   local wid = wid or api.nvim_get_current_win()
--   local match_groups = vim.tbl_map(function(l)
--     return l.group
--   end, fn.getmatches(wid))
--   return vim.tbl_contains(match_groups, gname)
-- end

return M
