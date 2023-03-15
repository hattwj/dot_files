scriptencoding utf-8
set encoding=utf-8

" Plugins will be downloaded under the specified directory.
"   Run :PlugInstall to download and install plugins
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
  " jsx highlighter
  Plug 'MaxMEllon/vim-jsx-pretty'
  " Left hand side git diff (+/-/~) sybols
  Plug 'airblade/vim-gitgutter'
  " Scala LSP
  " Plug 'scalameta/coc-metals', {'do': 'yarn install --frozen-lockfile'}
  " Static analysis suite
  Plug 'dense-analysis/ale'
  " Syntax highlighting for Dockerfiles
  Plug 'ekalinin/Dockerfile.vim'
  " Snippet support
  " Plug 'garbas/vim-snipmate'
  " Required dependency for snipmate
  Plug 'MarcWeber/vim-addon-mw-utils'
  " Markdown automatic previews, open in browser, likely won't work over ssh.
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
  " Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
  " File searching plugin
  Plug 'kien/ctrlp.vim'
  " Untested, colored parens highlighter
  Plug 'kien/rainbow_parentheses.vim'
  " File searching plugin / ag / ack based.
  Plug 'mileszs/ack.vim'
  " JS highlighting
  Plug 'pangloss/vim-javascript'
  " Gdiff / Gblame support
  Plug 'tpope/vim-fugitive'
  " General rails support
  Plug 'tpope/vim-rails'
  " Netrw enhancements, '-' to view parent directory
  Plug 'tpope/vim-vinegar'
  " Airline statusbar / git meta data viewer
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  " Generic ruby enhancements / code completion
  Plug 'vim-ruby/vim-ruby'
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Modify vimdiff to use a better algorithm (if supported)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("patch-8.1.0360")
  set diffopt+=internal,algorithm:patience
endif

""
" Vim :terminal configuration
""
" Set the default shell to use for :terminal
set shell=/bin/bash

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" tmux hack to allow ctrl-arrow passthrough in vim
" http://superuser.com/questions/401926/how-to-get-shiftarrows-and-ctrlarrows-working-in-vim-in-tmux
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if &term =~ '^screen'
  " tmux will send xterm-style keys when its xterm-keys option is on
  execute "set <xUp>=\e[1;*A"
  execute "set <xDown>=\e[1;*B"
  execute "set <xRight>=\e[1;*C"
  execute "set <xLeft>=\e[1;*D"
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("mac")
    " This is mac vim
  if has("gui_running")
    " Background Transparency
    set transparency=16
  endif
elseif !has("gui_running")
  " This is console Vim.
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => netrw interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" have netrw file browser in tree mode (Buggy)
" let g:netrw_liststyle= 3
" default mode
let g:netrw_liststyle= 1

" Open new files in a new tab when pressing <Enter> (Buggy)
let g:netrw_browse_split = 3
" let g:netrw_altv = 1

" Netrw previews should be around 30 lines
let g:netrw_winsize=50

"""
" Main interface
"""



" Use 256 colors for colorscheme
set t_Co=256
":colorscheme vibrantink
":colorscheme vividchalk
":colorscheme wombat
":colorscheme calmar256-dark
":colorscheme monokai
set background=dark
:colorscheme PaperColor

" Enable syntax highlighting
syntax enable

" Enable line numbering
set number

" Disable linewrapping
set nowrap

" Only syntax highlight the first 400 characters of a line
" Prevent Slowdown from long lines
set synmaxcol=400

" Set the textwidth to be 80 chars
"set textwidth=80

" Set to auto read when a file is changed from the outside
set autoread

" Set 7 lines to the cursors - when moving vertical..
"set so=7

" show the name of the current file being worked on at the BOTTOM of the screen
set ls=1
" show the name of the current file being worked on at the TOP of the screen
set showtabline=1
set wildmenu                    "Turn on WiLd menu (info bar on bottom of screen)
set wildmode=list:longest,full  "Format for wildmenu

set ruler "Always show current position

set cmdheight=1 "The commandbar height

"set hid "Change buffer - without saving

" Set backspace config
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

set ignorecase "Ignore case when searching
"set smartcase

"set search "Highlight search things

"set incsearch "Make search act like search in modern browsers
"set nolazyredraw "Don't redraw while executing macros

"set magic "Set magic on, for regular expressions

set showmatch "Show matching brackets when text indicator is over them
"set mat=2 "How many tenths of a second to blink

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Settings for tmp, backup and undo files
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set backupdir=$HOME/tmp//
set directory=$HOME/tmp//
set undodir=$HOME/tmp//

" Make folder automatically if it doesn't already exist.
if !isdirectory(expand(&undodir))
  call mkdir(expand(&undodir), "p")
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sudo Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Allow saving of files as sudo when I forgot to start vim using sudo.
fu! SudoSave()
  w ! sudo tee %
endf
command! -nargs=0 SudoSave call SudoSave()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim-Airline settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Fix airline to truncate on large branches
let g:airline#extensions#branch#displayed_head_limit = 10
let g:airline_powerline_fonts = 1
let g:airline_theme='molokai'
""
" Fallbacks if you don't have a patched font
" unicode symbols
"let g:airline_left_sep = '»'
"let g:airline_left_sep = '▶'
"let g:airline_right_sep = '«'
"let g:airline_right_sep = '◀'
"let g:airline_symbols.linenr = '␊'
"let g:airline_symbols.linenr = '␤'
"let g:airline_symbols.linenr = '¶'
"let g:airline_symbols.branch = '⎇'
"let g:airline_symbols.paste = 'ρ'
"let g:airline_symbols.paste = 'Þ'
"let g:airline_symbols.paste = '∥'
"let g:airline_symbols.whitespace = 'Ξ'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Copy Paste Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" map CTRL-E to end-of-line (insert and normal mode)
imap <C-e> <esc>$i<right>
nmap <C-e> $
vmap <C-e> $

" map CTRL-A to beginning-of-line (insert and normal mode)
imap <C-a> <esc>0i
nmap <C-e> 0

" Map Shift-A to select all text
nmap A ggVG

" CTRL-C to copy (visual mode)
" vmap <C-c> "+y
"<Ctrl-C> -- copy (goto visual mode and copy)
imap <C-C> <C-O>vgG
vmap <C-c> "+y

" CTRL-X to cut (visual mode)
vmap <C-x> xi

" CTRL-V to paste (insert and visual mode)
imap <C-v> <esc>Pi
vmap <C-v> <esc>Pi

" vim managed pastes
set nopaste

" use system clipboard by default
set clipboard=unnamed

"" Use CTRL-S for saving, also in Insert mode
noremap <C-S> :update<CR>
vnoremap <C-S> <C-C>:update<CR>
inoremap <C-S> <C-O>:update<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Cursor Navigation / Arrow Key Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable full mouse support (even in a terminal)
set mouse=a

"Map Control arrow L/R to prev next tabs
map <C-Left> :tabp<enter>
map <C-Right> :tabn<enter>

" Allow the arrow keys to wrap around lines
set whichwrap+=<,>,h,l,[,]

" Increase Command History Size
set history=10000

" Highlight search matches
set hlsearch

" Disable highlight when pressing escape
noremap <Space> :let @/ = "" <CR>

" Map pageup and page down keys
map <PageUp> <C-U>
map <PageDown> <C-D>
imap <PageUp> <C-O><C-U>
imap <PageDown> <C-O><C-D>
set nostartofline


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab
set shiftwidth=2
set tabstop=2
set smarttab
set smartindent
set autoindent

" Filetype extensions
set nocompatible
autocmd BufRead,BufNewFile *.rb,*.py,*.js,*.css,*.html,*.erb,*.yml,*.yaml set et ts=2 sts=2 sw=2
autocmd BufRead,BufNewFile *.json set noet ts=2 sts=2 sw=2
filetype on
filetype plugin indent on
filetype indent on

""
" Make tabs visible
""
"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59
" show tabs as triangle
set listchars=tab:▸\ ,
" Default to show-tabs=on
set list
" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" Set noexpandtab for makefiles, do not expand tabs to spaces for make files
" Makefiles will choke if they contain a line that starts with a space
let _curfile = expand("%:t")
if _curfile =~ "Makefile" || _curfile =~ "makefile" || _curfile =~ ".*\.mk" || _curfile =~ ".*\.json"
    set noexpandtab
endif

" Indent guides configuration
" https://github.com/nathanaelkane/vim-indent-guides/blob/master/README.markdown
" Use <leader-key>ig to activate tab guides
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1

"set lbr
"set tw=500

" Use shift-tab to unindent tabs
imap <S-Tab> <C-o><<


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OMNI COMPLETE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""i
" use CTRL-XO to enable
"set omnifunc=csscomplete#CompleteCSS
" use super-tab to enable
let g:SuperTabDefaultCompletionType = "<C-X><C-O>"
" Let supertab decide which contect to use
let g:SuperTabDefaultCompletionType = "context"

" Use Control XS for spell checking
set spell
nnoremap \s ea<C-X><C-S>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim tab guides
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Display the Full name of the current file
set statusline+=%F " filename
set laststatus=2


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim title bar
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:auto BufEnter * let &titlestring = hostname() . GetCurFile()
:set title titlestring=%<%F%=%l/%L-%P titlelen=70

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Fuzzy filename searching plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" add to runtime
set runtimepath^=~/.vim/bundle/ctrlp.vim
" Automatically use git for file ignoresd
" -- This is slow
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
" r = nearest git ancestor
" " a = current directory
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_match_window = 'results:100' " List at most 100 files
let g:ctrlp_match_window = 'bottom,order:btt,min:5,max:10,results:100'
let g:ctrlp_regexp = 1                   " Regex matching
let g:ctrlp_by_filename=0                " 0 for full_path
let g:ctrlp_reuse_window = 'netrw\|help\|quickfix' " Avoid clobbering these windows when using ctrlP
" Also ignore this if present
let g:ctrlp_custom_ignore = '\vpublic[\/](surveys)$'

" # 1 open new files in a new tab
" # 2 open new files in a new tab
" # 3 use space as a token separator
let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("e")': [],
  \ 'AcceptSelection("t")': ['<cr>', '<c-m>'],
  \ 'PrtAdd(".*")': ['<space>'],
  \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ack.vim Text searching plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use ag instead of Ack if it is available
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

function! FindGitRoot()
  let l:path = expand('%:p:h')
  if l:path != ''
    let l:gitArgs = '-C ' . l:path
  endif
  return system('git ' . l:gitArgs . ' rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction

function! GetCurFile()
  " First attempt to use the current file
  let l:curfile = expand('%:p:h')

  if empty(l:curfile)
    " Fall back to netrw current directory if the cur file is empty
    let l:curfile = b:netrw_curdir
  end
  return l:curfile
endfunction

" Search from git root if possible
command! -nargs=* Ag call Ag(<q-args>)
function! Ag(cmd='')
  " Get current git root
  let l:oldwd = getcwd()

  let l:curfile = GetCurFile()

  exec('cd ' . l:curfile)
  let l:root = FindGitRoot()

  if l:root != ''
    exec('cd ' . l:root)
  endif

  exec('Ack! '. a:cmd)
  exec('cd ' . l:oldwd)
endfunction

map <F2> :mksession! ~/.vim_session <cr> " Quick write session with F2
map <F3> :source ~/.vim_session <cr>     " And load session with F3

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Terminal Appearance
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""
" Transparent background colors
hi Normal ctermbg=none
highlight NonText ctermbg=none

"""
" 80 character line - black
set cc=80,120
hi ColorColumn ctermbg=black guibg=black

"""
" Strip trailing whitespaces on the following file types
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

"""
" Automatically trim trailing white space on save for these file types
autocmd FileType c,
  \cpp,
  \css,
  \cloudformation,
  \dockerfile,
  \html,
  \java,
  \javascript,
  \json,
  \markdown,
  \php,
  \python,
  \ruby,
  \scala,
  \sh,
  \vim,
  \yaml autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

"""
" Highlight trailing whitespace
highlight ExtraWhitespace ctermbg=DarkRed guibg=DarkRed
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/

"""
" Fix annoying 00~ ~01 characters that surround text that is pasted
" into the terminal. Related to 'bracketed paste mode'
" workaround for https://github.com/vim/vim/issues/1start671
if has("unix")
  let s:uname = system("echo -n \"$(uname)\"")
  if !v:shell_error && s:uname == "Linux"
    set t_BE=
  endif
endif

"""
" Vim GitGutter config
"  Update the gutter state every x milliseconds
set updatetime=100
highlight clear SignColumn
highlight GitGutterAdd ctermfg=green
highlight GitGutterChange ctermfg=yellow
highlight GitGutterDelete ctermfg=red
highlight GitGutterChangeDelete ctermfg=yellow

" Make the background for the line numbers transparent as well
highlight lineNr ctermbg=NONE

" Create a custom file type for cloudformation cfn.yaml files
augroup cfn_ft
  au!
  autocmd BufNewFile,BufRead *.cfn.yaml set filetype=cloudformation syntax=yaml
augroup END

"""
" Vim ALE Linter Config
" Always show linter gutter
let g:ale_sign_column_always = 1
" Disable linting on text change, will only lint on save instead
"let g:ale_lint_on_text_changed = "never"

" Lint on save
let g:ale_lint_on_save = 1

" Set this. Airline will handle the rest.
let g:airline#extensions#ale#enabled = 1
" Require vim restart to run linters that are not installed
let g:ale_cache_executable_check_failures = 1
" Set this variable to 1 to fix files when you save them.
let g:ale_fix_on_save = 0
let g:ale_fixers = {
      \   '*': ['remove_trailing_lines', 'trim_whitespace'],
      \   'ruby': ['prettier', 'rubocop'],
      \   'scala': [ 'scalafmt' ],
      \   'yaml': [ 'prettier' ]
      \ }

" Specify ruby linters, you'll likely want others enabled
"      \ 'scala': [ 'scalatest']
"      \ 'scala': [ 'metals' ]
let g:ale_linters = {
      \ 'ruby': ['solargraph', 'rubocop', 'reek', 'ruby'],
      \ 'scala': ['scalatest', 'scalafmt', 'metals']
      \ }

function! FindConfig(buffer) abort
    " The Config is always in the root directory
    return expand('%:p:h')
endfunction

let g:brazil_config_plugin_path = '/apollo/env/envImprovement/vim/amazon/brazil-config'

" With Plug
Plug g:brazil_config_plugin_path

au BufReadPost,BufNewFile Config setf brazil-config

call ale#linter#Define('brazil-config', {
    \ 'name': 'barium',
    \ 'lsp': 'stdio',
    \ 'executable': 'barium',
    \ 'command': '%e',
    \ 'project_root': function('FindConfig'),
    \})

" Set the executable for ALE to call to get Solargraph
" up and running in a given session
let g:ale_ruby_solargraph_executable = 'solargraph'
let g:ale_completion_enabled = 1

" Show a floating preview window for AleDetail on current line
let g:ale_cursor_detail=1
let g:ale_floating_preview = 1

"""
" SnipMate Configuration
"""
" Use new parser to prevent startup warning
let g:snipMate = { 'snippet_version' : 1 }

"""
" rainbowParenthesis configuration
"""
au VimEnter * RainbowParenthesesToggle       " On by default
au Syntax * RainbowParenthesesLoadRound      " ()
au Syntax * RainbowParenthesesLoadSquare     " []
au Syntax * RainbowParenthesesLoadBraces     " {}
" au Syntax * RainbowParenthesesLoadChevrons   " <>

 """
 " Vim-markdown preview configuration
 """
" set to 1, nvim will open the preview window after entering the markdown buffer
" default: 0
let g:mkdp_auto_start = 0

" set to 1, the nvim will auto close current preview window when change
" from markdown buffer to another buffer
" default: 1
let g:mkdp_auto_close = 1

" set to 1, the vim will refresh markdown when save the buffer or
" leave from insert mode, default 0 is auto refresh markdown as you edit or
" move the cursor
" default: 0
let g:mkdp_refresh_slow = 0

" set to 1, the MarkdownPreview command can be use for all files,
" by default it can be use in markdown file
" default: 0
let g:mkdp_command_for_global = 0

" set to 1, preview server available to others in your network
" by default, the server listens on localhost (127.0.0.1)
" default: 0
let g:mkdp_open_to_the_world = 0

" preview server port
let g:mkdp_port = 9000

" use custom IP to open preview page
" useful when you work in remote vim and preview on local browser
" more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
" default empty
let g:mkdp_open_ip = '127.0.0.1'

" specify browser to open preview page
" default: ''
let g:mkdp_browser = ''

" set to 1, echo preview page url in command line when open preview page
" default is 0
let g:mkdp_echo_preview_url = 1

" a custom vim function name to open preview page
" this function will receive url as param
" default is empty
let g:mkdp_browserfunc = 'g:EchoUrl'
function! g:EchoUrl(url)
  :echo a:url
endfunction

" options for markdown render
" mkit: markdown-it options for render
" katex: katex options for math
" uml: markdown-it-plantuml options
" maid: mermaid options
" disable_sync_scroll: if disable sync scroll, default 0
" sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
"   middle: mean the cursor position alway show at the middle of the preview page
"   top: mean the vim top viewport alway show at the top of the preview page
"   relative: mean the cursor position alway show at the relative positon of the preview page
" hide_yaml_meta: if hide yaml metadata, default is 1
" sequence_diagrams: js-sequence-diagrams options
" content_editable: if enable content editable for preview page, default: v:false
" disable_filename: if disable filename header for preview page, default: 0
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0
    \ }

" use a custom markdown style must be absolute path
" like '/Users/username/markdown.css' or expand('~/markdown.css')
let g:mkdp_markdown_css = ''

" use a custom highlight style must absolute path
" like '/Users/username/highlight.css' or expand('~/highlight.css')
let g:mkdp_highlight_css = ''

" preview page title
" ${name} will be replace with the file name
let g:mkdp_page_title = '「${name}」'

" recognized filetypes
" these filetypes will have MarkdownPreview... commands
let g:mkdp_filetypes = ['markdown']


""
" CodeSearch / Brazil integration config
""

" Source the CodeSearch plugin - WIP
let code_search_script = $HOME . '/dddot_files/config/basil.vim'
if filereadable(code_search_script)
  exec 'so ' . code_search_script
  " Command line flag to only show results from active packages
  let g:code_search_status = "status:active"

  " Limit code search results to these respositories
  let g:code_search_repo = "repo:Flagfish*,Elemental*"

  " Prefix if file is found in the current workflow default:
  " let g:code_search_file_found = "🌲"
  " let g:code_search_file_found = "🎉"

  " Prefix if file is found in the current workflow
  " let g:code_search_file_missing = "👿"
  " let g:code_search_file_missing = "❌"

  " Keybindings for Scratch buffer that displays results
  let g:code_search_kb_add = "u"
  let g:code_search_kb_remove = "r"
  let g:code_search_kb_open = '<CR>'
endif
