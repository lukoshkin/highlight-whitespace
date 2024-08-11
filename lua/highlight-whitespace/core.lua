--- Variable namings:
--- cl - current line
--- (u|h|t)ws - (unwanted|highlight|trailing) whitespace

local api = vim.api
local fn = vim.fn

local M = {}
M.ns_id = api.nvim_create_namespace "HWS"
M.buffer_cached_matches = {}
--- Note matches are bound to a window, however, I associate them to a buffer
M.win_group_match = {}
M.win_cl_match = {}

local function is_in_match_groups(gname, wid)
  local wid = wid or api.nvim_get_current_win()
  local match_groups = vim.tbl_map(function(l)
    return l.group
  end, fn.getmatches(wid))
  return vim.tbl_contains(match_groups, gname)
end

local function two_wins_with_one_buffer_on_tabpage()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local buf_seen = {}
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if buf_seen[buf] then
      return true
    end
    buf_seen[buf] = true
  end
  return false
end

function M.clear_uws_match(args)
  local bnr = (args or {}).buf or fn.bufnr()
  local bname = api.nvim_buf_get_name(bnr)
  local wid = fn.bufwinid(bnr)

  if M.win_group_match[bname] then
    api.nvim_win_call(wid, function()
      for gname, mid in pairs(M.win_group_match[bname]) do
        M.win_group_match[bname][gname] = nil
        if is_in_match_groups(gname, wid) then
          fn.matchdelete(mid, wid)
        end
      end
    end)
  end
end

function M.match_uws()
  local ft = api.nvim_buf_get_option(0, "filetype")
  local uws_pat_list = M.cfg.palette[ft] or M.cfg.palette["other"]
  local uws_pattern = table.concat(vim.tbl_keys(uws_pat_list), "\\|")

  --- Do not continue if the current win is not modifiable or not normal,
  --- there is no unwanted whitespace in the buffer,
  --- or the buffer filetype is blacklisted.
  if
    not vim.opt.modifiable:get()
    or api.nvim_win_get_config(0).relative ~= ""
    or vim.tbl_contains(M.cfg.filetype_blacklist, ft)
    or fn.search(uws_pattern, "nw") == 0
  then
    return
  end

  if two_wins_with_one_buffer_on_tabpage() then
    M.clear_uws_match()
  end

  local bname = api.nvim_buf_get_name(0)
  M.win_group_match[bname] = M.win_group_match[bname] or {}
  api.nvim_buf_clear_namespace(0, M.ns_id, 0, -1)

  for pat, color in pairs(uws_pat_list) do
    local gname = "HWS_" .. color:gsub("#", "")
    if not M.win_group_match[bname][gname] then
      M.win_group_match[bname][gname] = fn.matchadd(gname, pat, 10) -- default priority is 10
    end
    api.nvim_set_hl(M.ns_id, gname, { bg = color })
    api.nvim_win_set_hl_ns(0, M.ns_id)
  end
end

function M.get_matches_from_cache()
  local bname = api.nvim_buf_get_name(0)
  if M.buffer_cached_matches[bname] then
    fn.setmatches(M.buffer_cached_matches[bname])
    M.buffer_cached_matches[bname] = nil -- Do we really need this?
    return
  end
  M.match_uws()
end

function M.save_matches_to_cache_and_clear(args)
  local bnr = (args or {}).buf or fn.bufnr()
  local bname = api.nvim_buf_get_name(bnr)
  local wid = fn.bufwinid(bnr)
  M.buffer_cached_matches[bname] = fn.getmatches(wid)
  M.win_group_match[bname] = nil

  --- TODO: maybe add check for non-modifiable buffers?
  if api.nvim_win_get_config(wid).relative == "" then
    fn.clearmatches()
  end
end

function M.no_match_cl()
  --- Before suppressing tws's hl with no_match's hl,
  --- make sure the previous no_match's hl-s are deleted.
  M.clear_no_match_cl()
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

function M.clear_no_match_cl()
  local wid = api.nvim_get_current_win()
  if M.win_cl_match[wid] then
    if is_in_match_groups "CL_TWS" then
      fn.matchdelete(M.win_cl_match[wid])
      M.win_cl_match[wid] = nil
    end
  end

  --- Update UWS matches after leaving the insert mode
  M.match_uws()
end

function M.prune_dicts()
  --- No need to check the win is normal, right?
  --- Though, we don't create a kw-pair in table for non-normal wins.
  M.win_cl_match[api.nvim_get_current_win()] = nil
  M.win_group_match[api.nvim_buf_get_name(0)] = nil
end

return M
