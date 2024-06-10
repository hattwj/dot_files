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

    " Get the Git remote URL and remove newline from response:
    " Examples:
    "   Github urls:
    "   - https://github.com/some_user/some_repo.git
    "   - git@github.com:some_user/some_repo.git
    "   Bitbucket urls:
    "   - ssh://git@bitbucket.some_company.com:9876/~some_user/some_repo.git
    "   CodeCommit urls:
    "   - ssh://git-codecommit.us-east-2.amazonaws.com/v1/repos/some_repo
    "   - https://git-codecommit.us-east-2.amazonaws.com/v1/repos/some_repo
    let l:remote_url = substitute(system('git config --get remote.' . l:remote_name . '.url'), "\\n", '', 'g')
    if l:remote_url == ''
      echoerr "Error: no remote found with the name '" . l:remote_name ."'"
      return
    end

    if stridx(l:remote_url, 'bitbucket') > -1
      echo s:GitBitbucketFileURL(l:remote_url, l:branch)
    elseif stridx(l:remote_url, 'github.com') > -1
      echo s:GithubFileURL(l:remote_url, l:branch)
    elseif stridx(l:remote_url, 'git-codecommit') > -1 && stridx(l:remote_url, 'amazonaws.com') > -1
      echo s:GitAWSCodeCommitFileURL(l:remote_url, l:remote_name, l:branch)
    else
      echoerr "Error: unrecognized git host pattern - " . l:remote_url
    endif
  finally
    " Ensure that we return to the original working directory
    execute 'cd ' . l:original_dir
  endtry
endfunction

function! s:GitBitbucketFileURL(remote_url, branch_name='')
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
  let l:remote_url = substitute(l:remote_url, 'ssh://', 'https://', 'n')

  " Switch based on user vs project based link
  if l:remote_url =~ ":\\d\\+/\\~"
    let l:remote_url = substitute(l:remote_url, ":\\d\\+/\\~", '/users/', 'n')
  else
    let l:remote_url = substitute(l:remote_url, ":\\d\\+/", '/projects/', 'n')
  endif

  " [^/]
  let l:remote_url = substitute(l:remote_url, '/\([^/]\+\).git', '/repos/\1', 'n')
  if a:branch_name == ''
    let l:branch_name = s:URLEncode(substitute(system('git rev-parse --abbrev-ref HEAD'), "\\n", '', 'g'))
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


function! s:GithubFileURL(remote_url, branch_name='')
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
  let l:remote_url = substitute(l:remote_url, 'ssh://', 'https://', 'n')

  " remote '.git' ending from the URL
  let l:remote_url = substitute(l:remote_url, '/\([^/]\+\).git', '/\1', 'n')
  if a:branch_name == ''
    " No branch name was specified, so use the current branch name
    let l:branch_name = s:URLEncode(substitute(system('git rev-parse --abbrev-ref HEAD'), "\\n", '', 'g'))
  else
    " Use the branch name that was provided
    let l:branch_name = a:branch_name
  endif

  if l:relative_path == ''
    " Construct the URL link with no line number
    " https://github.com/some_user/some_repo/tree/mainline/some/file/path/here.txt
    let l:url_link = l:remote_url . '/tree/' . l:branch_name . '/' . l:relative_path
  else
    " Construct the URL link with line number
    " https://github.com/some_user/some_repo/tree/mainline/some/file/path/here.txt#L45
    let l:url_link = l:remote_url . '/tree/' . l:branch_name . '/' . l:relative_path . '#L' . line('.')
  endif

  return l:url_link
endfunction

function! s:GitAWSCodeCommitFileURL(remote_url, remote_name, branch_name='')
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
  let l:remote_url = substitute(l:remote_url, 'ssh://', 'https://', 'n')

  " remote '.git' ending from the URL
  let l:remote_url = substitute(l:remote_url, '/\([^/]\+\).git', '/\1', 'n')


  let l:remote_url = substitute(l:remote_url, '//git-codecommit.', '//', 'n')
  let l:remote_url = substitute(l:remote_url, '.amazonaws.com', '.console.aws.amazon.com', 'n')
  let l:remote_url = substitute(l:remote_url, '.amazon.com\/v1\/repos\/', '.amazon.com/codesuite/codecommit/repositories/', 'n')


  if a:branch_name == ''
    " No branch name was specified, so use the current branch name
    let l:branch_name = s:URLEncode(substitute(system('git rev-parse --abbrev-ref HEAD'), "\\n", '', 'g'))
  else
    " Use the branch name that was provided
    let l:branch_name = a:branch_name
  endif

  if l:relative_path == ''
    " Construct the URL link with no line number
    " https://us-east-2.console.aws.amazon.com/codesuite/codecommit/repositories/some_repo/browse/refs/heads/mainline/--/relpath/to_file.txt
    let l:url_link = l:remote_url . '/browse/refs/heads/' . l:branch_name . '/--/' . l:relative_path
  else
    " Construct the URL link with line number
    " https://us-east-2.console.aws.amazon.com/codesuite/codecommit/repositories/some_repo/browse/refs/heads/mainline/--/relpath/to_file.txt?lines=2-2
    let l:url_link = l:remote_url . '/browse/refs/heads/' . l:branch_name . '/--/' . l:relative_path . '?lines=' . line('.') . '-' . line('.')
  endif

  return l:url_link
endfunction

function! s:URLEncode(input)
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
