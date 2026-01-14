return {
  {
    "neoclide/coc.nvim",
    branch = "release",
    lazy = false,
    config = function()
      vim.cmd([[
        " Some servers have issues with backup files, see #649.
        set nobackup
        set nowritebackup

        " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
        " delays and poor user experience.
        set updatetime=300

        " Always show the signcolumn, otherwise it would shift the text each time
        " diagnostics appear/become resolved.
        set signcolumn=yes

        " Use tab for trigger completion with characters ahead and navigate.
        inoremap <silent><expr> <TAB>
              \ coc#pum#visible() ? coc#pum#next(1):
              \ CheckBackspace() ? "\<Tab>" :
              \ coc#refresh()
        inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

        " Make <CR> to accept selected completion item or notify coc.nvim to format
        inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

        function! CheckBackspace() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        " Use <c-space> to trigger completion.
        inoremap <silent><expr> <c-space> coc#refresh()

        " Use `[d` and `]d` to navigate diagnostics
        nmap <silent> [d <Plug>(coc-diagnostic-prev)
        nmap <silent> ]d <Plug>(coc-diagnostic-next)

        " Use Telescope for gotos
        nmap <silent> gd :<C-u>Telescope coc definitions<cr>
        nmap <silent> gy :<C-u>Telescope coc type_definitions<cr>
        nmap <silent> gi :<C-u>Telescope coc implementations<cr>
        nmap <silent> gr :<C-u>Telescope coc references<cr>

        " Use K to show documentation in preview window.
        nnoremap <silent> K :call ShowDocumentation()<CR>

        function! ShowDocumentation()
          if CocAction('hasProvider', 'hover')
            call CocActionAsync('doHover')
          else
            call feedkeys('K', 'in')
          endif
        endfunction

        " Highlight symbol under cursor on CursorHold
        autocmd CursorHold * silent call CocActionAsync('highlight')

        " Remap for rename current word
        nmap <leader>rr <Plug>(coc-rename)

        " Remap for format selected region
        xmap =f  <Plug>(coc-format-selected)

        augroup CocGroup
          autocmd!
          autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
          autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        augroup end

        " Applying codeAction to the selected region.
        xmap ,a  <Plug>(coc-codeaction-selected)
        nmap ,a  <Plug>(coc-codeaction-selected)

        " Remap keys for applying code actions at the cursor position
        nmap ,ac  <Plug>(coc-codeaction-cursor)
        nmap ,as  <Plug>(coc-codeaction-source)
        nmap ,qf  <Plug>(coc-fix-current)

        " Remap keys for applying refactor code actions
        nmap <silent> ,re <Plug>(coc-codeaction-refactor)
        xmap <silent> ,r  <Plug>(coc-codeaction-refactor-selected)
        nmap <silent> ,r  <Plug>(coc-codeaction-refactor-selected)

        " Map function and class text objects
        xmap if <Plug>(coc-funcobj-i)
        omap if <Plug>(coc-funcobj-i)
        xmap af <Plug>(coc-funcobj-a)
        omap af <Plug>(coc-funcobj-a)
        xmap ic <Plug>(coc-classobj-i)
        omap ic <Plug>(coc-classobj-i)
        xmap ac <Plug>(coc-classobj-a)
        omap ac <Plug>(coc-classobj-a)

        " Remap <C-f> and <C-b> for scroll float windows/popups.
        nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
        nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
        inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
        inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
        vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
        vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

        " Use CTRL-S for selections ranges.
        nmap <silent> <C-s> <Plug>(coc-range-select)
        xmap <silent> <C-s> <Plug>(coc-range-select)

        " Use `:Format` to format current buffer
        command! -nargs=0 Format :call CocActionAsync('format')
        nmap =f :Format<cr>

        " Use `:Fold` to fold current buffer
        command! -nargs=? Fold :call     CocAction('fold', <f-args>)

        " use `:OR` for organize import of current buffer
        command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

        " Using Telescope for COC if possible
        nnoremap <silent> ,l  :<C-u>Telescope coc<cr>
        nnoremap <silent> ,d  :<C-u>Telescope coc diagnostics<cr>
        nnoremap <silent> ,c  :<C-u>Telescope coc commands<cr>
        nnoremap <silent> ,o  :<C-u>Telescope coc document_symbols<cr>
        nnoremap <silent> ,s  :<C-u>Telescope coc workspace_symbols<cr>
        nnoremap <silent> ,p  :<C-u>CocListResume<CR>
        nnoremap <silent> ,j  :<C-u>CocNext<CR>
        nnoremap <silent> ,k  :<C-u>CocPrev<CR>

        let g:coc_global_extensions = [
              \ 'coc-json',
              \ 'coc-marketplace',
              \ 'coc-rust-analyzer',
              \ 'coc-xml',
              \ 'coc-emmet',
              \ 'coc-diagnostic',
              \ 'coc-explorer',
              \ ]

        " explorer
        let g:coc_explorer_global_presets = {
              \   '.dot': {
              \     'position': 'floating', 
              \     'root-uri': '~/dotfiles',
              \   },
              \   'floating': {
              \     'position': 'floating',
              \     'open-action-strategy': 'sourceWindow',
              \   },
              \   'simplify': {
              \     'position': 'left',
              \     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
              \   }
              \ }

        nmap <space>nn :CocCommand explorer --preset simplify --no-toggle<CR>
        nmap <space>nf :CocCommand explorer --preset floating<CR>
        nmap <space>nd :CocCommand explorer --preset .dot<CR>
        autocmd ColorScheme *
              \ hi CocExplorerNormalFloatBorder guifg=transparent guibg=transparent

        " Auto refresh
        function! s:enter_explorer()
          if &filetype == 'coc-explorer'
            call CocActionAsync('runCommand', 'explorer.doAction', 'closest', ['refresh'])
          endif
        endfunction

        augroup CocExplorerCustom
          autocmd!
          autocmd BufEnter * call <SID>enter_explorer()
        augroup END
      ]])
    end,
  },
}
