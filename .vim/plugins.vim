let need_to_install_plugins = 0
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    let need_to_install_plugins = 1
endif

call plug#begin()

"syntax
"Plug 'airblade/vim-gitgutter'
Plug 'sheerun/vim-polyglot'

"status bar
Plug 'itchyny/lightline.vim'
"Plug 'maxinbaz/lightline-ale'       "tema para lightline

"typing
Plug 'alvan/vim-closetag'			"cierra tags html
Plug 'tpope/vim-surround'           "encierra texto entre comillas, parentesis
Plug 'chun-yang/auto-pairs'

"themes
Plug 'gruvbox-community/gruvbox'
Plug 'shinchu/lightline-gruvbox.vim'
"Plug 'vim-airline/vim-airline'

"tree
Plug 'scrooloose/nerdtree'

"Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

"file search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

""autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'sirver/ultisnips'         "snipets handler

"ide
Plug 'yggdroot/indentline'
Plug 'scrooloose/nerdcommenter'


call plug#end()
