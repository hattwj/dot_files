
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

command! -nargs=0 ProjectRoot2 call ProjectRoot2()
function! ProjectRoot2()
  if exists("b:netrw_curdir")
    exec('cd ' . b:netrw_curdir)
    let l:git_root = FindGitRoot()
    if !empty(l:git_root)
      exec('cd ' . l:git_root)
    endif
  else
    exec('ProjectRoot')
  endif
endfunction

" Search from git root if possible
command! -nargs=* Ag call Ag(<q-args>)
function! Ag(cmd='')
  " Get current git root
  let l:oldwd = getcwd()

  let l:curfile = GetCurDir()

  exec('cd ' . l:curfile)
  let l:root = FindGitRoot()

  if l:root != ''
    exec('cd ' . l:root)
  endif

  exec('Ack! '. a:cmd)
  exec('cd ' . l:oldwd)
endfunction
