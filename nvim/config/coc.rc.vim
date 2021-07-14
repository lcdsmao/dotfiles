UsePlugin 'coc.nvim'
UsePlugin 'fzf'
UsePlugin 'fzf.vim'
UsePlugin 'coc-fzf'

" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" let g:coc_snippet_next = '<tab>'

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" With coc-paris: https://github.com/neoclide/coc-pairs/issues/13#issuecomment-478998416
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[d` and `]d` to navigate diagnostics
nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rr <Plug>(coc-rename)

" Remap for format selected region
" xmap <leader>f  <Plug>(coc-format-selected)
" nmap <leader>f  <Plug>(coc-format-selected)

" augroup mygroup
"   autocmd!
"   " Setup formatexpr specified filetype(s).
"   autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
"   " Update signature help on jump placeholder
"   autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
" augroup end

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

nmap =f :Format<cr>

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Using CocList
nnoremap <silent> ,l  :<C-u>CocFzfList<cr>
nnoremap <silent> ,d  :<C-u>CocFzfList diagnostics<cr>
nnoremap <silent> ,b  :<C-u>CocFzfList diagnostics --current-buf<CR>
nnoremap <silent> ,e  :<C-u>CocFzfList extensions<cr>
nnoremap <silent> ,c  :<C-u>CocFzfList commands<cr>
nnoremap <silent> ,o  :<C-u>CocFzfList outline<cr>
nnoremap <silent> ,s  :<C-u>CocFzfList symbols<cr>
nnoremap <silent> ,p  :<C-u>CocFzfListResume<CR>
nnoremap <silent> ,j  :<C-u>CocNext<CR>
nnoremap <silent> ,k  :<C-u>CocPrev<CR>

" " Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap ,a  <Plug>(coc-codeaction-selected)
nmap ,a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap ,ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap ,qf  <Plug>(coc-fix-current)
" nnoremap <silent> ,a  :<C-u>CocAction<CR>

let g:coc_global_extensions = [
      \ 'coc-json',
      \ 'coc-marketplace',
      \ 'coc-rust-analyzer',
      \ 'coc-xml',
      \ 'coc-flutter',
      \ 'coc-emmet',
      \ 'coc-diagnostic',
      \ 'coc-explorer',
      \ 'coc-pairs'
      \ ]

" git
" navigate chunks of current buffer
" nmap [g <Plug>(coc-git-prevchunk)
" nmap ]g <Plug>(coc-git-nextchunk)
" show chunk diff at current position
" nmap gsi <Plug>(coc-git-chunkinfo)
" show commit contains current position
" nmap gci <Plug>(coc-git-commit)
" create text object for git chunks
" omap ig <Plug>(coc-git-chunk-inner)
" xmap ig <Plug>(coc-git-chunk-inner)
" omap ag <Plug>(coc-git-chunk-outer)
" xmap ag <Plug>(coc-git-chunk-outer)

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

" Use preset argument to open it
nmap <space>nn :CocCommand explorer --preset simplify --no-toggle<CR>
nmap <space>nf :CocCommand explorer --preset floating<CR>
nmap <space>nd :CocCommand explorer --preset .dot<CR>
autocmd ColorScheme *
      \ hi CocExplorerNormalFloatBorder guifg=transparent guibg=transparent
" \ | hi CocExplorerNormalFloat guibg=transparent
" auto refresh
" see: https://github.com/weirongxu/coc-explorer/issues/356
" see: https://github.com/weirongxu/coc-explorer/issues/161
autocmd User CocDiagnosticChange,CocGitStatusChange
    \ call CocActionAsync('runCommand', 'explorer.doAction', 'closest', ['refresh'])
