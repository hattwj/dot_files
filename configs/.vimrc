" Minimal .vimrc — fallback for when nvim is not available.
" Full editor config lives in ~/.config/nvim/ (LazyVim).

set nocompatible
syntax on
set number
set expandtab
set shiftwidth=2
set tabstop=2
set mouse=a
set backspace=indent,eol,start
set ignorecase
set smartcase
set hlsearch
set incsearch
set wildmenu
set wildmode=list:longest,full
set ruler
set laststatus=2
set clipboard=unnamed
set nowrap
set autoread
set history=10000

" Allow arrow keys to wrap around lines
set whichwrap+=<,>,h,l,[,]

" Disable highlight with Space
noremap <Space> :let @/ = "" <CR>

" Use a dark colorscheme if available, fall back gracefully
set background=dark
silent! colorscheme desert

" Temp/backup/undo files
set backupdir=$HOME/tmp//
set directory=$HOME/tmp//
set undodir=$HOME/tmp//
if !isdirectory(expand(&undodir))
  call mkdir(expand(&undodir), "p")
endif
