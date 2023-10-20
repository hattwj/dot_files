" Link current file back to the git repo web UI
command! -nargs=* CodeLink call s:CodeLink(<q-args>)
function! s:CodeLink(qargs='')
  let l:args = split(a:qargs)

  if len(l:args) > 2
    echoerr "CodeLink only allows 0 - 2 parameters."
    return
  elseif len(l:args) == 2
    " IE: CodeLink origin mainline
    let l:branch = l:args[1]
    let l:remote_name = l:args[0]
  elseif len(l:args) == 1
    " IE: CodeLink mainline
    let l:branch = l:args[0]
    let l:remote_name = 'origin'
  else
    " IE: CodeLink
    let l:branch = ''
    let l:remote_name = 'origin'
  endif

  " Ensure that we are in the correct directory
  let l:original_dir = getcwd()
  try
    if empty(expand('%:p'))
      " We're not in a file, maybe netrw instead? Get the current directory
      execute 'cd ' . b:netrw_curdir
    else
      " Use the directory of the current file
      execute 'cd ' . expand('%:p:h')
    endif
    " Get the Git remote URL
    let l:remote_url = substitute(system('git config --get remote.' . l:remote_name . '.url'), "\\n", '', 'g')
    if stridx(l:remote_url, 'bitbucket') > -1
      echo GitBitbucketFileURL(l:remote_url, l:branch)
    elseif stridx(l:remote_url, 'github.com') > -1
      echo GithubFileURL(l:remote_url, l:branch)
    else
      echoerr "Error: unrecognized git host - " . l:remote_url
    endif
  finally
    execute 'cd ' . l:original_dir
  endtry
endfunction

function! GithubFileURL(remote_url, branch_name='')
  " Get the current file's path
  let l:file_path = expand('%:p')
  if empty(l:file_path)
    " Fall back to netrw current directory if the cur file is empty
    let l:file_path = b:netrw_curdir
    let l:relative_path = ''
  else
    " Get the relative path within the repository
    let l:relative_path = substitute(system('git ls-files --full-name ' . shellescape(l:file_path)), "\\n", '', 'g')
  endif

  " Convert ssh to https
  let l:remote_url = substitute(a:remote_url, 'ssh://git@', 'https://', 'n')

  " [^/]
  let l:remote_url = substitute(l:remote_url, '/\([^/]\+\).git', '/\1', 'n')
  if a:branch_name == ''
    let l:branch_name = URLEncode(substitute(system('git rev-parse --abbrev-ref HEAD'), "\\n", '', 'g'))
  else
    let l:branch_name = a:branch_name
  endif

  if l:relative_path == ''
    " Construct the URL link with no line number
    let l:url_link = l:remote_url . '/tree/' . l:branch_name . '/' . l:relative_path
  else
    " Construct the URL link with line number
    let l:url_link = l:remote_url . '/tree/' . l:branch_name . '/' . l:relative_path . '#' . line('.')
  endif

  return l:url_link
endfunction


function! GitBitbucketFileURL(remote_url, branch_name='')
  " Get the current file's path
  let l:file_path = expand('%:p')
  if empty(l:file_path)
    " Fall back to netrw current directory if the cur file is empty
    let l:file_path = b:netrw_curdir
    let l:relative_path = ''
  else
    " Get the relative path within the repository
    let l:relative_path = substitute(system('git ls-files --full-name ' . shellescape(l:file_path)), "\\n", '', 'g')
  endif

  " Convert ssh to https
  let l:remote_url = substitute(a:remote_url, 'ssh://git@', 'https://', 'n')

  " Switch based on user vs project based link
  if l:remote_url =~ ":\\d\\+/\\~"
    let l:remote_url = substitute(l:remote_url, ":\\d\\+/\\~", '/users/', 'n')
  else
    let l:remote_url = substitute(l:remote_url, ":\\d\\+/", '/projects/', 'n')
  endif

  " [^/]
  let l:remote_url = substitute(l:remote_url, '/\([^/]\+\).git', '/repos/\1', 'n')
  if a:branch_name == ''
    let l:branch_name = URLEncode(substitute(system('git rev-parse --abbrev-ref HEAD'), "\\n", '', 'g'))
  else
    let l:branch_name = a:branch_name
  endif

  if l:relative_path == ''
    " Construct the URL link with no line number
    let l:url_link = l:remote_url . '/browse/' . l:relative_path . '?at=refs%2Fheads%2F' . l:branch_name
  else
    " Construct the URL link with line number
    let l:url_link = l:remote_url . '/browse/' . l:relative_path . '?at=refs%2Fheads%2F' . l:branch_name . '#' . line('.')
  endif

  return l:url_link
endfunction

function! URLEncode(input)
  let l:encoded = substitute(a:input, ' ', '%20', 'g')
  let l:encoded = substitute(l:encoded, '!', '%21', 'g')
  let l:encoded = substitute(l:encoded, '"', '%22', 'g')
  let l:encoded = substitute(l:encoded, '#', '%23', 'g')
  let l:encoded = substitute(l:encoded, '&', '%26', 'g')
  let l:encoded = substitute(l:encoded, "'", '%27', 'g')
  let l:encoded = substitute(l:encoded, '(', '%28', 'g')
  let l:encoded = substitute(l:encoded, ')', '%29', 'g')
  let l:encoded = substitute(l:encoded, '*', '%2A', 'g')
  let l:encoded = substitute(l:encoded, '+', '%2B', 'g')
  let l:encoded = substitute(l:encoded, ',', '%2C', 'g')
  let l:encoded = substitute(l:encoded, '/', '%2F', 'g')
  let l:encoded = substitute(l:encoded, '_', '%5F', 'g')
  let l:encoded = substitute(l:encoded, '\~', '%7E', 'g')

  return l:encoded
endfunction
