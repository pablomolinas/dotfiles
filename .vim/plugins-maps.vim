
"fzf
:noremap <C-p> :GFiles<CR>

" Coc navigation keys.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> <C-u> :call CocAction('doHover')<CR>
nmap <silent>rn <Plug>(coc-rename)                      "rename functionality
