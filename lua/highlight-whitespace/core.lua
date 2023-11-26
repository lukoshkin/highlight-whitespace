local api = vim.api
local fn = vim.fn

local M = {}
M.win_group_match = {}
M.win_cl_match = {}


--- (u|h|t)ws - (unwanted|highlight|trailing) whitespace
local function _clear_uws_match ()
  local wid = api.nvim_get_current_win()
  if M.win_group_match[wid] then
    local match_groups = vim.tbl_map(
      function (l) return l.group end, fn.getmatches())
    for name, mid in pairs(M.win_group_match[wid]) do
      if mid >= 0 then
        M.win_group_match[wid][name] = -1
        if vim.tbl_contains(match_groups, name) then
          fn.matchdelete(mid)
        end
      end
    end
  end
end


function M.clear_uws_match ()
  if not M.clear_on_winleave then
    return
  end

  _clear_uws_match()
end


function M.match_uws ()
  local ft = api.nvim_buf_get_option(0, 'filetype')
  local uws_pat_list = M.palette[ft] or M.palette['other']
  local uws_pattern = table.concat(vim.tbl_keys(uws_pat_list), '\\|')
  local pos = api.nvim_win_get_cursor(0)

  --- Do not continue if the current win is not modifiable,
  --- not normal, or there is no trailing whitespace.
  if not vim.opt.modifiable:get()
      -- or vim.tbl_contains(M.blacklist, ft)
      or api.nvim_win_get_config(0).relative ~= ''
      or fn.search(uws_pattern) <= 0
  then
    --- If such a win, clear the HWS_* highlighting in it.
    _clear_uws_match()
    return
  end

  api.nvim_win_set_cursor(0, pos)
  local wid = api.nvim_get_current_win()
  M.win_group_match[wid] = M.win_group_match[wid] or {}
  local match_groups = vim.tbl_map(
    function (l) return l.group end, fn.getmatches())

  for pat, color in pairs(uws_pat_list) do
    --- Create a valid group name from `color`.
    local name = 'HWS_' .. color:gsub('[^a-zA-Z0-9_.@-]', '')
    local not_in_MG = not vim.tbl_contains(match_groups, name)

    --- If not registered - register, if broken or cleared with `clearmatches()`
    --- (that is not listed in `getmatches()`), then update (= `matchadd`)
    if not M.win_group_match[wid][name] then
      M.win_group_match[wid][name] = fn.matchadd(name, pat)
      api.nvim_set_hl(0, name, { bg = color })
    else
      if M.win_group_match[wid][name] < 0 or not_in_MG then
        M.win_group_match[wid][name] = fn.matchadd(name, pat)
      end
    end
  end
end


function M.no_match_cl ()
  --- Before suppressing tws's hl with no_match's hl,
  --- make sure the previous no_match's hl-s are deleted.
  M.clear_no_match_cl()
  --- Remove '$' (otherwise, won't work) and specify that "uncoloring"
  --- applies only to the current line ('\%.l'), up to the cursor ('\%.c'),
  --- and only to trailing whitespace (`main_pat` .. '\(\s*\S\)\@!').
  local cl_tws_pat = M.tws:gsub('%$', '') .. '\\%.l\\%.c' .. '\\(\\s*\\S\\)\\@!'
  --- fg color should have a not NONE value.
  api.nvim_set_hl(0, 'CL_TWS', { fg = '#ffffff' })
  --- Otherwise, it will not work.
  local wid = api.nvim_get_current_win()
  M.win_cl_match[wid] = fn.matchadd('CL_TWS', cl_tws_pat, 11)
  --- Default priority is 10, we set just a bit higher.
end


function M.clear_no_match_cl ()
  local wid = api.nvim_get_current_win()
  if M.win_cl_match[wid] then
    fn.matchdelete(M.win_cl_match[wid])
    M.win_cl_match[wid] = nil
  end

  M.match_uws()
end


function M.prune_dicts ()
  --- No need to check the win is normal, right?
  --- Though, we don't create a kw-pair in table for non-normal wins.
  local wid = api.nvim_get_current_win()
  M.win_cl_match[wid] = nil
  M.win_group_match[wid] = nil
end


return M
