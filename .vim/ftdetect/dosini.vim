
function! s:DetectDosIni()
    if getline(1) =~ '^#!.*\<ini\>'
        set filetype=dosini
    endif
endfunction

autocmd BufNewFile,BufRead * call s:DetectDosIni()

