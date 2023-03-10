local api = vim.api
local fn = vim.fn

local tws = {}
tws.win_group_match = {}
tws.win_cl_match = {}


function tws.match_tws ()
  --- Not sure about `search()` performance. If it is comparable
  --- to calls of `matchadd()` and `hi`, then the amount of work in
  --- the function is doubled.
  local tws_pattern = table.concat(tws.patterns, '\\|')
  local pos = api.nvim_win_get_cursor(0)
  local wid = api.nvim_get_current_win()

  --- Do not continue if the current win is not modifiable,
  --- not normal, or there is no trailing whitespace.
  if not vim.opt.modifiable:get()
      or not api.nvim_win_get_config(0).relative == ''
      or fn.search(tws_pattern) <= 0 then
    return
  end

  api.nvim_win_set_cursor(0, pos)
  local ft = api.nvim_buf_get_option(0, 'filetype')
  local bg = tws.palette[ft] or tws.palette.default
  api.nvim_set_hl(0, 'TrailingWS', { bg = bg })

  if not tws.win_group_match[wid] then
      tws.win_group_match[wid] = fn.matchadd('TrailingWS', tws_pattern)
  else
    --- If matches were removed with `clearmatches()`,
    --- checking the length of getmatches() list may help.
    if tws.win_group_match[wid] < 0 or #fn.getmatches() == 0 then
        tws.win_group_match[wid] = fn.matchadd('TrailingWS', tws_pattern)
    end
  end
end


function tws.clear_tws_match ()
  local wid = api.nvim_get_current_win()
  if tws.win_group_match[wid]
      and tws.win_group_match[wid] >= 0 then
    fn.matchdelete(tws.win_group_match[wid])
    tws.win_group_match[wid] = -1
  end
end


function tws.no_match_cl ()
  --- Before suppressing tws's hl with no_match's hl,
  --- make sure the previous no_match's hl-s are deleted.
  tws.clear_no_match_cl()
  --- Assuming that the first pattern is given for trailing whitespace,
  --- we remove '$' (otherwise, won't work) and specify that "uncoloring"
  --- only applies to the current line (\%.l) and up to the cursor (\%.c).
  local tws_pattern = tws.patterns[1]:gsub('%$', '') .. '\\%.l\\%.c'
  --- fg color should have a not NONE value.
  api.nvim_set_hl(0, 'CL_TWS', { fg='#ffffff' })
  --- Otherwise, it will not work.
  local wid = api.nvim_get_current_win()
  tws.win_cl_match[wid] = fn.matchadd('CL_TWS', tws_pattern, 11)
  --- Default priority is 10, we set just a bit higher.
end


function tws.clear_no_match_cl ()
  local wid = api.nvim_get_current_win()
  if tws.win_cl_match[wid] then
    fn.matchdelete(tws.win_cl_match[wid])
    tws.win_cl_match[wid] = nil
  end

  tws.match_tws()
end


function tws.prune_dicts ()
  --- No need to check the win is normal, right?
  --- Though, we don't create a kw-pair in table for non-normal wins.
  local wid = api.nvim_get_current_win()
  tws.win_cl_match[wid] = nil
  tws.win_group_match[wid] = nil
end


return tws
