"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colorschemes
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let os = substitute(system('uname'), "\n", "", "")
if has("mac")
	" Color scheme
	:colorscheme vividchalk
	
	if has("gui_running")
	    " Background Transparency
	    set transparency=22
	endif
elseif os=="Linux"
	if has("gui_running")
	  " Color scheme
	  :colorscheme vividchalk
    else
      " Color scheme that wont mess with transparent background
      " in a terminal (Ubuntu)	
      :colorscheme wombat 
    endif

elseif has("unix")
	" Color scheme
	:colorscheme wombat
endif

" Enable syntax highlighting
syntax enable

" Enable line numbering
set number

" Indent guides configuration
" https://github.com/nathanaelkane/vim-indent-guides/blob/master/README.markdown
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1



" Disable linewrapping
set nowrap

" Set the textwidth to be 80 chars
"set textwidth=80



" Set to auto read when a file is changed from the outside
set autoread


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

" CTRL-C to copy (visual mode)
vmap <C-c> y

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
" => Navigation / Arrow Key Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"Map Control arrow L/R to prev next tabs
map <C-Left> :tabp<enter>
map <C-Right> :tabn<enter>

" Allow the arrow keys to wrap around lines
set whichwrap+=<,>,h,l,[,]

" Increase Command History Size
set history=7000

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

" Set noexpandtab for makefiles
let _curfile = expand("%:t") 
if _curfile =~ "Makefile" || _curfile =~ "makefile" || _curfile =~ ".*\.mk"
    set noexpandtab
endif

"set lbr
"set tw=500

" Use shift-tab to unindent tabs
imap <S-Tab> <C-o><<

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the curors - when moving vertical..
"set so=7

"set wildmenu "Turn on WiLd menu

set ruler "Always show current position

set cmdheight=2 "The commandbar height

"set hid "Change buffer - without saving

" Set backspace config
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

set ignorecase "Ignore case when searching
"set smartcase

"set hlsearch "Highlight search things

"set incsearch "Make search act like search in modern browsers
"set nolazyredraw "Don't redraw while executing macros 

"set magic "Set magic on, for regular expressions

set showmatch "Show matching bracets when text indicator is over them
"set mat=2 "How many tenths of a second to blink

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OMNI COMPLETE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""i
" use CTRL-XO to enable
set omnifunc=csscomplete#CompleteCSS
" use super-tab to enable
let g:SuperTabDefaultCompletionType = "<C-X><C-O>"
" Let supertab decide which contect to use
let g:SuperTabDefaultCompletionType = "context"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim tab guides
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use <leader-key>ig to activate tab guides

" No sound on errors
"set noerrorbells
"set novisualbell
"set t_vb=
"set tm=500

"" line numbering
"set number
"
"" map CTRL-E to end-of-line (insert and normal mode)
"imap <C-e> <esc>$i<right>
"nmap <C-e> $
"vmap <C-e> $
"" map CTRL-A to beginning-of-line (insert and normal mode)
"imap <C-a> <esc>0i
"nmap <C-e> 0
"" CTRL-C to copy (visual mode)
"vmap <C-c> y
"" CTRL-X to cut (visual mode)
"vmap <C-x> xi
"
"" CTRL-V to paste (insert mode)
"imap <C-v> <esc>Pi
"
"" Use CTRL-S for saving, also in Insert mode
"noremap <C-S> :update<CR>
"vnoremap <C-S> <C-C>:update<CR>
"inoremap <C-S> <C-O>:update<CR>
""Map Control arrow L/R to prev next tabs
"map <C-Left> :tabp<enter>
"map <C-Right> :tabn<enter>
"" Allow the arrow keys to wrap around lines
"set whichwrap+=<,>,h,l,[,]
"
"" SOLARIS ONLY STUFF
"" Specifically enable syntax highlighting
"syntax enable
"" Fix backspaces in Solaris
"set bs=2
"
"" Disable linewrapping
"set nowrap
"
"" Increase Command History Size
"set history=7000
"
"" Highlight search matches
"set hlsearch
" Disable highlight when pressing escape
"noremap <Space> :let @/ = "" <CR> 
"
" Map pageup and page down keys
"map <PageUp> <C-U>
"map <PageDown> <C-D>
"imap <PageUp> <C-O><C-U>
"imap <PageDown> <C-O><C-D>
"set nostartofline
