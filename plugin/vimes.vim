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

" vim:set et sw=2:
