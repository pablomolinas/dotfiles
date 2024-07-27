
let g:coc_global_extensions = []
if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
    let g:coc_global_extensions += ['coc-prettier']
endif

if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
    let g:coc_global_extensions += ['coc-eslint']
endif

" coc automatic behavior where cursoring over a word
"function! ShowDocIfNoDiagnostic(timer_id)
"    if(coc#util#has_float() == 0)
"        silent call CocActionAsync('doHover')
"    endif
"endfunction

"function! s:show_hover_doc()
"    call timer_start(500, 'ShowDocIfNoDiagnostic')
"endfunction

"autocmd CursorHoldI * :call <SID>show_hover_doc()
"autocmd CursorHold * :call <SID>show_hover_doc()

" vim-go
"let g:go_def_mapping_enabled = 0 "disable goDefinition
