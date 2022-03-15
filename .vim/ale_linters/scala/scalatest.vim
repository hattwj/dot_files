" Description: scalatest linter for scala files.
"

call ale#Set('scala_scalatest_executable', 'bb-scala-ale')
call ale#Set('scala_scalatest_options', '')

function! ale_linters#scala#scalatest#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'scala_scalatest_executable')
endfunction

function! ale_linters#scala#scalatest#GetCommand(buffer) abort
    return ale#Escape(ale_linters#scala#scalatest#GetExecutable(a:buffer))
    \   . ale#Var(a:buffer, 'scala_scalatest_options')
    \   . ' ' . expand('%')
endfunction

function! ale_linters#scala#scalatest#Opscript(buffer, lines) abort
    " Look for lines like the following.
    " :set incsearch to test your patterns in real-time !
    "
    "ft_lstsize.c: Error!
    "Error: SPACE_REPLACE_TAB    (line:  17, col:  11): Found space when expecting tab
    "ft_calloc.c: OK!
    "ft_memcpy.c: Error!
    "Error: SPACE_AFTER_KW       (line:  22, col:  19): Missing space after keyword
    "test.c: Error!
    "Error: SPACE_BEFORE_FUNC    (line:   6, col:   4): space before function name
    "Error: WRONG_SCOPE_COMMENT  (line:  12, col:   9): Comment is invalid in this scope
    "ft_isalnum.c: OK!

    let l:pattern = '\(^[^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\)'
    let l:output = []
    let l:curr_file = ''

    "A good tip to check what is at each index of l:match is to run inside Vim :
    ":let pattern='\(^\(\h\+\.[ch]\): \(\w\+\)!$\|^Error: \h\+\s\+(line:\s\+\(\d\+\),\s\+col:\s\+\(\d\+\)):\s\+\(.*\)\)'
    ":echo ale#util#GetMatches(['ft_lstsize.c: Error!'], pattern)
    "                          ^^^^^^^^^^^^^^^^^^^^^^
    "                          Replace with each line you want to  match
    "

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if l:match[1] == 'OK'
            continue
        else
            call add(l:output, {
            \   'type': l:match[1],
            \   'filename': l:match[2],
            \   'lnum': str2nr(l:match[3]),
            \   'col': str2nr(l:match[4]),
            \   'text': "Scalatest : " . l:match[5],
            \   'lint_file': 1,
            \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('scala', {
\   'name': 'scalatest',
\   'output_stream': 'both',
\   'executable': function('ale_linters#scala#scalatest#GetExecutable'),
\   'command': function('ale_linters#scala#scalatest#GetCommand'),
\   'callback': 'ale_linters#scala#scalatest#Opscript',
\})
