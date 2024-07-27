" change leader for space
let mapleader = " "

" remap to normal mode
:imap ii <Esc>

" word movement
imap <S-Left> <Esc>bi
map <S-Left> b
imap <S-Right> <Esc><Right>wi
nmap <S-Right> w

" indent/unindent with tab/shift-tab
nmap <Tab> >>
nmap <S-tab> <<
imap <S-Tab> <Esc><<i
vmap <Tab> >gv
vmap <S-Tab> <gv

" quick semi
nnoremap <Leader>; $a;<Esc>     " ; al final de la linea
nnoremap <Leader>: $a:<Esc>     " : al final de la linea

" faster search
nmap <Leader>s <Plug>(easymotion-s2)

"run current file
"nnoremap <Leader>xn :!node %<CR>        " ejecuta el archivo actual en node
"nnoremap <Leader>xp :!python %<CR>      " ejecuta el archivo actual en python

" shift+arrow selection
nmap <S-Up> v<Up>
nmap <S-Down> v<Down>
nmap <S-Left> v<Left>
nmap <S-Right> v<Right>
vmap <S-Up> <Up>
vmap <S-Down> <Down>
vmap <S-Left> <Left>
vmap <S-Right> <Right>
imap <S-Up> <Esc>v<Up>
imap <S-Down> <Esc>v<Down>
imap <S-Left> <Esc>v<Left>
imap <S-Right> <Esc>v<Right>


let g:is_mouse_enabled = 1
noremap <silent> <Leader>m :call ToggleMouse()<CR>

function ToggleMouse()
    if g:is_mouse_enabled == 1
        echo "Mouse OFF"
        set mouse=
        let g:is_mouse_enabled = 0
    else
        echo "Mouse ON"
        set mouse=a
        let g:is_mouse_enabled = 1
    endif
endfunction

" wrap toggle
setlocal nowrap
noremap <silent> <Leader>w :call ToggleWrap()<CR>

function ToggleWrap()
    if &wrap
        echo "Wrap OFF"
        setlocal nowrap
        set virtualedit=all
        silent! nunmap <buffer> <Up>
        silent! nunmap <buffer> <Down>
        silent! nunmap <buffer> <Home>
        silent! nunmap <buffer> <End>
        silent! iunmap <buffer> <Up>
        silent! iunmap <buffer> <Down>
        silent! iunmap <buffer> <Home>
        silent! iunmap <buffer> <End>
    else
        echo "Wrap ON"
        setlocal wrap linebreak nolist
        set virtualedit=
        setlocal display+=lastline
        noremap  <buffer> <silent> <Up>   gk
        noremap  <buffer> <silent> <Down> gj
        noremap  <buffer> <silent> <Home> g<Home>
        noremap  <buffer> <silent> <End>  g<End>
        inoremap <buffer> <silent> <Up>   <C-o>gk
        inoremap <buffer> <silent> <Down> <C-o>gj
        inoremap <buffer> <silent> <Home> <C-o>g<Home>
        inoremap <buffer> <silent> <End>  <C-o>g<End>
    endif
endfunction

" move through split windows
nmap <leader><Up> :wincmd k<CR>
nmap <leader><Down> :wincmd j<CR>
nmap <leader><Left> :wincmd h<CR>
nmap <leader><Right> :wincmd l<CR>
nmap <C-k> :wincmd k<CR>
nmap <C-j> :wincmd j<CR>
nmap <C-h> :wincmd h<CR>
nmap <C-l> :wincmd l<CR>

"slit resize
nnoremap <Leader>> 10<C-w>>
nnoremap <Leader>< 10<C-w><

" move through buffers
map <C-PageDown> :bp!<CR>
map <C-PageUp> :bn!<CR>
map <leader>x :bd<CR>

" copy, cut and paste
vmap <C-c> "+y
vmap <C-x> "+c
"vmap <C-v> c<ESC>"+p
"imap <C-v> <ESC>"+pa
nnoremap <C-v> :call XPaste()<CR>
vnoremap <C-v> <ESC>:call XPaste()<CR>
inoremap <C-v> <ESC>:call XPaste()<CR>a
nnoremap <C-S-v> :call XPaste()<CR>
vnoremap <C-S-v> <ESC>:call XPaste()<CR>
inoremap <C-S-v> <ESC>:call XPaste()<CR>a

" save with ctrl+s
:nmap <C-s> :w<CR>
:imap <C-s> <ESC>:w<CR>a
nnoremap <Leader>w :w<CR>   "guardar
nnoremap <Leader>q :q<CR>   "salir


function! XPaste()
    set paste
    normal! "+gp
    set nopaste
endfunction

" move lines CTRL+SHIFT+Up/Down
nnoremap <C-S-Up> :m-2<CR>
nnoremap <C-S-Down> :m+<CR>
inoremap <C-S-Up> <Esc>:m-2<CR>
inoremap <C-S-Down> <Esc>:m+<CR>
" move selected lines up one line
xnoremap <C-S-Up>  :m-2<CR>gv=gv
" move selected lines down one line
xnoremap <C-S-Down> :m'>+<CR>gv=gv
"shift+end select line to end
nnoremap <S-End> v$
inoremap <S-End> <ESC>v$

