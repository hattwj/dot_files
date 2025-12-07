
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ack.vim Text searching plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use ag instead of Ack if it is available
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

""
" Auto format json in current file to make it easier to read
command! -nargs=0 JsonPretty call JsonPretty()
function! JsonPretty()
  exec('%!jq .')
endfunction

"""
" Strip trailing whitespaces on the following file types
command! -nargs=0 WhitespacesStrip call StripTrailingWhitespaces()
fun! StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

command! -nargs=0 FindGitRoot echo FindGitRoot()
function! FindGitRoot()
  let l:path = expand('%:p:h')
  if l:path != ''
    let l:gitArgs = '-C ' . l:path
  endif
  return system('git ' . l:gitArgs . ' rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction

function! GetCurDir()
  " First attempt to use the current dir
  let l:curfile = expand('%:p:h')

  if empty(l:curfile)
    " Fall back to netrw current directory if the cur file is empty
    let l:curfile = b:netrw_curdir
  end
  return l:curfile
endfunction

command! -nargs=* ProjectRoot2 call ProjectRoot2(<q-args>)
function! ProjectRoot2(...)
  if exists("b:netrw_curdir")
    exec('cd ' . b:netrw_curdir)
    let l:git_root = FindGitRoot()
  else
    let l:git_root = FindGitRoot()
  endif

  " Call ProjectRoot2("x") to scope of results
  " - Helps with Telescope to limit results to a subdirectory
  if a:0 > 0 && a:1 != ''
    if a:1 == '--clear'
      let g:projectRootSubDir = ''
    else 
      let g:projectRootSubDir = a:1
    endif
  endif

  if exists("g:projectRootSubDir") && !empty(l:git_root)
    if isdirectory(l:git_root . '/' . g:projectRootSubDir)
      let l:git_root = l:git_root . '/' . g:projectRootSubDir
    endif 
  endif 
  
  if !empty(l:git_root)
    exec('cd ' . l:git_root)
  endif
  return l:git_root
endfunction

" Search from git root if possible
"command! -nargs=* Ag call Ag(<q-args>)
"function! Ag(cmd='')
"  " Get current git root
"  let l:oldwd = getcwd()
"
"  let l:curfile = GetCurDir()
"
"  exec('cd ' . l:curfile)
"  let l:root = FindGitRoot()
"
"  if l:root != ''
"    exec('cd ' . l:root)
"  endif
"
"  exec('Ack! '. a:cmd)
"  exec('cd ' . l:oldwd)
"endfunction


function! GotoFileWithLineNumber()
    let l:line = getline('.')
    let l:file = expand('<cfile>')
    
    " Handle markdown link syntax
    let l:markdown_link = matchlist(l:line, '\[.*\](\([^)]\+\))')
    if len(l:markdown_link) > 1
        let l:file = l:markdown_link[1]
    endif
    
    " Extract line number range if present
    let l:range = matchlist(l:file, '#L\(\d\+\)\(-L\(\d\+\)\)\?')
    let l:file = substitute(l:file, '#L\d\+\(-L\d\+\)\?$', '', '')
    
    " Open the file
    execute "edit " . l:file
    
    " Jump to line number if specified
    if len(l:range) > 1
        execute l:range[1]
        if len(l:range) > 3 && l:range[3] != ''
            execute "normal! V" . l:range[3] . "G"
        endif
    endif
endfunction
" Modify the default "gf" to be line number aware
autocmd FileType * nnoremap <buffer> gf :call GotoFileWithLineNumber()<CR>
