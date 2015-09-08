scriptencoding utf-8
set encoding=utf-8

execute pathogen#infect()


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
:colorscheme calmar256-dark

" Enable syntax highlighting
syntax enable

" Enable line numbering
set number

" Disable linewrapping
set nowrap

" Only syntax highlight the first 200 characters of a line
" Prevent Slowdown from long lines
set synmaxcol=200

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
" Sudo Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

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
set shiftwidth=4
set tabstop=4
set smarttab
set smartindent
set autoindent

" Filetype extensions
set nocompatible
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
filetype on
filetype plugin indent on
filetype indent on

" Set noexpandtab for makefiles, do not expand tabs to spaces for make files
" Makefiles will choke if they contain a line that starts with a tab
let _curfile = expand("%:t") 
if _curfile =~ "Makefile" || _curfile =~ "makefile" || _curfile =~ ".*\.mk"
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
set omnifunc=csscomplete#CompleteCSS
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
" Fuzzy searching plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" add to runtime
set runtimepath^=~/.vim/bundle/ctrlp.vim
" Automatically use git for file ignores
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
" Also ignore this if present
let g:ctrlp_custom_ignore = '\vpublic[\/](surveys)$'
" open new files in a new tab
let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("e")': [],
  \ 'AcceptSelection("t")': ['<cr>', '<c-m>'],
  \ }


" Transparent background colors
hi Normal ctermbg=none
highlight NonText ctermbg=none

" 80 character line - black
set cc=80
hi ColorColumn ctermbg=black guibg=black

