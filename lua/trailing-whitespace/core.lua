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

  if not vim.opt.modifiable:get()
      or vim.fn.search(tws_pattern) <= 0 then
    return
  end

  api.nvim_win_set_cursor(0, pos)
  local ft = api.nvim_buf_get_option(0, 'filetype')
  local bg = tws.palette[ft] or tws.palette.default
  api.nvim_set_hl(0, 'TrailingWS', { bg = bg })

  local wid = api.nvim_get_current_win()
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
    vim.fn.matchdelete(tws.win_group_match[wid])
    tws.win_group_match[wid] = -1
  end
end


function tws.no_match_cl ()
  local wid = api.nvim_get_current_win()
  local tws_pattern = '\\%.l' .. tws.patterns[1]
  -- local tws_pattern = '\\%.l' .. table.concat(tws.patterns, '\\|\\%.l')

  --- fg color should have a not NONE value.
  api.nvim_set_hl(0, 'CL_TWS', { fg='#ffffff' })
  --- Otherwise, it will not work.
  tws.win_cl_match[wid] = vim.fn.matchadd('CL_TWS', tws_pattern, 11)
  --- Default priority is 10, we set just a bit higher.
end


function tws.clear_no_match_cl ()
  local wid = api.nvim_get_current_win()
  if tws.win_cl_match[wid] then
    vim.fn.matchdelete(tws.win_cl_match[wid])
    tws.win_cl_match[wid] = nil
  end

  tws.match_tws()
end


return tws
