"" Negative lookbehind since it is unlikely that it will be
"" trailing underscores after a filename's extension.
au! BufWinEnter,WinEnter *\(_\)\@<! call MatchTWS()
"" BufWinLeave should not trigger MatchTWS; otherwise, plugins
"" like nvim-notify or fidget, that rely on floating windows, will
"" clear match groups after their buffers are removed from a window.
au! WinLeave *\(_\)\@<! call ClearTWSMatch()
au! InsertEnter * call NoMatchCL()
au! InsertLeave * call ClearNoMatchCL()


let g:tws_wins = {}

"" Altering defaults
let g:tws_pattern = get(g:, 'tws_pattern', '\s\+$')
let g:tws_color_any = get(g:, 'tws_color_any', {
      \ 'ctermbg': 211, 'guibg': 'PaleVioletRed' })
let g:tws_color_md = get(g:, 'tws_color_md', {
      \ 'ctermbg': 138, 'guibg': 'RosyBrown' })


function! MatchTWS ()
  "" Not sure about `search()` performance. If it is comparable
  "" to calls of `matchadd()` and `hi`, then the amount of work in
  "" the function is doubled.
  let l:pos = getpos('.')
  if !&modifiable || search(g:tws_pattern) <= 0
    return
  endif

  call setpos('.', l:pos)
  let l:cmd = 'hi TrailingWS'

  if &ft != 'markdown'
    let l:cmd .= ' ctermbg='.g:tws_color_any.ctermbg
    let l:cmd .= ' guibg='.g:tws_color_any.guibg
    execute(l:cmd)
  else
    let l:cmd .= ' ctermbg='.g:tws_color_md.ctermbg
    let l:cmd .= ' guibg='.g:tws_color_md.guibg
    execute(l:cmd)
  endif

  let l:winid = win_getid()
  if !has_key(g:tws_wins, l:winid)
    let g:tws_wins[l:winid] = matchadd('TrailingWS', g:tws_pattern)
  else
    "" If matches were removed with `clearmatches()`,
    "" checking the length of getmatches() list may help.
    if g:tws_wins[l:winid] < 0 || len(getmatches()) == 0
      let g:tws_wins[l:winid] = matchadd('TrailingWS', g:tws_pattern)
    endif
  endif
endfunction


function! ClearTWSMatch ()
  let l:winid = win_getid()
  if has_key(g:tws_wins, l:winid) && g:tws_wins[l:winid] >= 0
    call matchdelete(g:tws_wins[l:winid])
    let g:tws_wins[l:winid] = -1
  endif
endfunction


function! NoMatchCL ()
  "" '\%.l' - seems like has been added recently.
  "" Will not work for Vimscript. (The Lua plugin does manage it.)
  let l:tws_pattern = '\%' . line('.') . 'l' . g:tws_pattern
  "" fg colors should be set to some value, not NONE.
  hi CL_TWS ctermfg=231 guifg=#ffffff
  "" Otherwise, it will not work.
  let w:tws_cl = matchadd('CL_TWS', l:tws_pattern, 11)
  "" Default priority is 10, we set just a bit higher.
endfunction


function! ClearNoMatchCL ()
  if exists('w:tws_cl')
    call matchdelete(w:tws_cl)
    unlet w:tws_cl
  endif

  call MatchTWS()
endfunction
