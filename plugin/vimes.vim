" vimes.vim - Vim IME System
" Author: Daniel P. Wright (http://dpwright.com)

if exists("g:loaded_vimes") || v:version < 700 || &cp
  finish
endif
let g:loaded_vimes = 1

function! vimes#convert_string(str_in)
  let str_out = a:str_in
  let start = 0
  let end = strlen(str_out) - start
  while(start < end)
    for i in [1,2,3,4]
      let idx = i - 1
      let current_substr = strpart(str_out, start, i)
      if has_key(g:hiragana_lookup[idx], current_substr)
        let rep = g:hiragana_lookup[idx][current_substr]
        let str_out = substitute(str_out, current_substr, rep, "")
        let start += strlen(rep) - 1
        let end = strlen(str_out)
        break
      end
    endfor

    let start += 1
  endwhile

  return str_out
endfunction

function! s:operator(type, op) abort
  let sel_save = &selection
  let cb_save = &clipboard
  let reg_save = @@
  try
    set selection=inclusive clipboard-=unnamed clipboard-=unnamedplus
    if a:type ==# 'line'
      silent exe "normal! '[V']".a:op
    elseif a:type ==# 'block'
      silent exe "normal! `[\<C-V>`]".a:op
    else
      silent exe "normal! `[v`]".a:op
    endif
    return @@
  finally
    let @@ = reg_save
    let &selection = sel_save
    let &clipboard = cb_save
  endtry
endfunction

function! s:roma_hira_op(type) abort
  let romaji = s:operator(a:type, "y")

  let reg_save = @@
  try
    let @@ = vimes#convert_string(romaji)
    normal! gvp`[
  finally
    let @@ = reg_save
  endtry
endfunction

nnoremap <silent> <Plug>VimesRomajiToHiragana  :<C-U>set opfunc=<SID>roma_hira_op<CR>g@
xnoremap <silent> <Plug>VimesRomajiToHiragana  :<C-U>call <SID>roma_hira_op(visualmode())<CR>
nmap <buffer> crh <Plug>VimesRomajiToHiragana
xmap <buffer> crh <Plug>VimesRomajiToHiragana

" vim:set et sw=2:
