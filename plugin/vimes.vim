" vimes.vim - Vim IME System
" Author: Daniel P. Wright (http://dpwright.com)

if exists("g:loaded_vimes") || v:version < 700 || &cp
  finish
endif
let g:loaded_vimes = 1

" Globals {{{1
let g:kanji_start_point = 0
let g:state = 'inactive'
" }}}1

" Character conversion {{{1
function! vimes#complete(findstart, base) abort
  if a:findstart
    return g:kanji_start_point
  else
    let google_out = system("curl -s --data \"langpair=ja-Hira|ja\" --data \"text=" . a:base . "\" http://www.google.com/transliterate")
    let matches = ParseJSON('{ "matches": ' . google_out . '}')["matches"][0][1]
    call add(matches, a:base)
    return {'words': matches}
  end
endfunction

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
" }}}1

" Movement operators {{{1
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

function! s:hira_kan_op(type) abort
  let g:kanji_start_point = col("'[") - 1
  silent exe "normal! `]"
  set completefunc=vimes#complete
  call feedkeys("a\<C-x>\<C-u>", "n")
endfunction
" }}}1

" Vimes Interactive Mode {{{1
function! vimes#toggle()
  if g:state ==# 'inactive'
    let g:state = 'idle'
  else
    let g:state = 'inactive'
  endif
endfunction

function! vimes#statusline()
  return '[Vimes: ' . g:state . ']'
endfunction
" }}}1

" Mappings {{{1
nnoremap <silent> <Plug>VimesHiraganaToKanji :<C-U>set opfunc=<SID>hira_kan_op<CR>g@
xnoremap <silent> <Plug>VimesHiraganaToKanji <SID>hira_kan_op(visualmode())
nmap <buffer> chj <Plug>VimesHiraganaToKanji
xmap <buffer> chj <Plug>VimesHiraganaToKanji

nnoremap <silent> <Plug>VimesRomajiToHiragana  :<C-U>set opfunc=<SID>roma_hira_op<CR>g@
xnoremap <silent> <Plug>VimesRomajiToHiragana  :<C-U>call <SID>roma_hira_op(visualmode())<CR>
nmap <buffer> crh <Plug>VimesRomajiToHiragana
xmap <buffer> crh <Plug>VimesRomajiToHiragana

noremap  <silent> <leader>j :call vimes#toggle()<cr>
inoremap <silent> <leader>j <esc>:call vimes#toggle()<cr>a
" }}}1

" vim:set et sw=2:
