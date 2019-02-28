" enable filetype plugins
filetype plugin on
filetype indent on

" enable auto read when a file is modified externally
set autoread

" always show the current position
set ruler

" height of the command bar
set cmdheight=2

" configure backspace so it acts as expected
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" try to be smart about case when searching
set ignorecase
set smartcase

" highlight search results
set hlsearch

" show matching brackets when cursor is over a bracket
set showmatch

" no annoying sounds on errors
set noerrorbells
set novisualbell

" enable syntax highlighting
set t_Co=256
syntax enable
colorscheme desert256

" set the standard encoding and language
set encoding=utf8

" disable backup files
set nobackup
set nowb
set noswapfile

" use a tab width of 4 spaces
set shiftwidth=4
set tabstop=4

" use spaces instead of tabs
set expandtab
set smarttab

" key bindings
map [1;3D :tabprevious<CR>
imap [1;3D <C-O>:tabprevious<CR>

map [1;3C :tabnext<CR>
imap [1;3C <C-O>:tabnext<CR>

