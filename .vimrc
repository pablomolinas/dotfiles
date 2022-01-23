set number
set relativenumber
set mouse=a             "enable mouse interactions
set numberwidth=1       "ancho de columna de numeros
set clipboard=unnamed
syntax on
set showcmd
set ruler
set cursorline
set encoding=utf-8
set fileformat=unix
set noswapfile          " no create swapfiles
set nobackup            " no backup, use git
set backspace=indent,eol,start
set undodir=~/.vim/undodir
set undofile
set showmatch
set sw=2
set hidden              "evitar que vim pida salvar al cambiar entre buffers
set viminfo='25,\"50,n~/.viminfo    "archivo historial linea de comandos

"indent always on
set smartindent
set autoindent

so ~/.vim/plugins.vim
so ~/.vim/plugin-config.vim
so ~/.vim/maps.vim

colorscheme gruvbox
let g:gruvbox_contrast_dark = "hard"
set laststatus=2    "always show statusbar
set noshowmode

""" searching
set hlsearch        "highligh matches
set incsearch       "incremental search
set ignorecase      "searches are case sensitive
set smartcase       "unless they contain at least one capital letter

if has("gui_running")
    set lines=69 columns=100
endif

" enable 256 colors
set t_Co=256
set t_ut=

" sane editing
set tabstop=4
set shiftwidth=4
set softtabstop=4
set colorcolumn=80
set expandtab
set guicursor=  " mover cursor en bloque
set scrolloff=4 " offset de visualizacion al hacer scroll

filetype on
filetype plugin indent on
autocmd FileType html setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType css setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType javascript, typescript, javascriptreact, typescriptreact setlocal tabstop=2 shiftwidth=2 softtabstop=2

" code folding
set foldmethod=indent
set foldlevel=99

" restore place in file from previous session
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
