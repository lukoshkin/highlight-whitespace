--- Variable namings:
--- cl - current line
--- (u|h|t)ws - (unwanted|highlight|trailing) whitespace

local utils = require "highlight-whitespace.core_utils"
local api = vim.api
local fn = vim.fn

local M = {}
M.ns_id = api.nvim_create_namespace "HWS"
M.buffer_cached_matches = {}
--- Note matches are bound to a window, however, I associate them to a buffer
M.win_group_match = {}
M.win_cl_match = {}

function M.cache_and_clear_uws_match(opts)
  opts = opts or {}
  opts.target = opts.target or "current"
  if not vim.tbl_contains({ "current", "all_but_current" }, opts.target) then
    error "Impl.error: opts.target must be 'current' or 'all_but_current'"
  end

  local this_ft = api.nvim_get_option_value("filetype", { buf = 0 })
  local this_wid = api.nvim_get_current_win()
  -- print("registered for", opts.target, ":", vim.inspect(M.win_group_match))
  -- print("matches:", vim.inspect(fn.getmatches()))
  for id, ft_matches in pairs(M.win_group_match) do
    local bname
    if id:endswith(this_wid) then
      bname = utils.strip_wid(id, this_wid)
    else
      goto skip_id
    end
    for ft, matches in pairs(ft_matches) do
      if opts.target == "current" and ft == this_ft then
        M.buffer_cached_matches[bname] = fn.getmatches()
        goto continue
      end

      if opts.target ~= "current" and ft ~= this_ft then
        goto continue
      end

      goto skip_ft
      ::continue::
      for _, mid in pairs(matches) do
        fn.matchdelete(mid)
      end
      M.win_group_match[id][ft] = nil
      M.buffer_cached_matches[bname] = nil
      ::skip_ft::
    end
    ::skip_id::
  end
end

function M.match_uws()
  local ft = api.nvim_get_option_value("filetype", { buf = 0 })
  local uws_pat_list = M.cfg.palette[ft] or M.cfg.palette["other"]

  if utils.is_untargetable() then
    return
  end

  local id = utils.group_in_focus_match_id()
  M.win_group_match[id] = M.win_group_match[id] or {}
  api.nvim_buf_clear_namespace(0, M.ns_id, 0, -1)

  for pat, color in pairs(uws_pat_list) do
    if fn.search(pat, "nw") == 0 then
      goto skip
    end

    M.win_group_match[id][ft] = M.win_group_match[id][ft] or {}
    local local_matches = M.win_group_match[id][ft]
    local gname = "HWS_" .. color:gsub("#", "")
    if local_matches[gname] == nil then
      local_matches[gname] = fn.matchadd(gname, pat, 10)
      --- The default priority is already 10, but let's be explicit
    end
    api.nvim_set_hl(M.ns_id, gname, { bg = color })
    api.nvim_win_set_hl_ns(0, M.ns_id)
    ::skip::
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
    fn.matchdelete(M.win_cl_match[wid])
    M.win_cl_match[wid] = nil
  end

  --- Update UWS matches after leaving the insert mode
  M.match_uws()
end

return M
