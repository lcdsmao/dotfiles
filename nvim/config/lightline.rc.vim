UsePlugin 'lightline.vim'

let g:lightline = {
      \ 'colorscheme': 'dogrun',
      \ 'active': {
      \   'left': [['mode', 'paste'],
      \             ['branch', 'readonly', 'filename']],
      \   'right': [['lineinfo'],
      \             ['percent'],
      \             ['fileencoding'],
      \             ['cocstatus', 'cocwarning', 'cocerror']],
      \ },
      \ 'component': {
      \   'lineinfo': '%3l:%-2v ¶',
      \ },
      \ 'component_expand': {
      \   'cocwarning': 'LightlineCocWarning',
      \   'cocerror': 'LightlineCocError',
      \ },
      \ 'component_type': {
      \   'cocwarning': 'warning',
      \   'cocerror': 'error',
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \   'branch': 'LightlineFugitive',
      \   'readonly': 'LightlineReadonly',
      \   'cocstatus': 'LightlineCocStatus',
      \ },
      \ 'separator': { 'left': '', 'right': ''},
      \ 'subseparator': { 'left': '❯', 'right': '❮'}
      \ }

function! LightlineFilename() abort
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' ∙' : ''
  return filename . modified
endfunction

function! LightlineModified(n) abort
  let winnr = tabpagewinnr(a:n)
  return gettabwinvar(a:n, winnr, '&modified') ? '∙' : gettabwinvar(a:n, winnr, '&modifiable') ? '' : '-'
endfunction

function! LightlineReadonly() abort
  if &filetype == "help"
    return ""
  elseif &readonly
    return "\u2b64"
  else
    return ""
  endif
endfunction

function! LightlineFugitive() abort
  let branch = FugitiveHead()
  return branch !=# '' ? ' '.branch : ''
endfunction

function! LightlineCocWarning() abort
  let info = get(b:, 'coc_diagnostic_info', {})
  return get(info, 'warning', 0) != 0 ? '∙ ' . info['warning'] : ''
endfunction

function! LightlineCocError() abort
  let info = get(b:, 'coc_diagnostic_info', {})
  return get(info, 'error', 0) != 0 ? '∙ ' . info['error'] : ''
endfunction

function! LightlineCocStatus() abort
  return get(g:, 'coc_status', '')
endfunction

augroup UpdateLightline
  autocmd!
  autocmd User CocDiagnosticChange call lightline#update()
augroup END

let g:lightline.tabline = {
      \ 'active': [ 'tabnum', 'filename', 'modified' ],
      \ 'inactive': [ 'tabnum', 'filename', 'modified' ]
      \ }

let g:lightline.tabline_subseparator = { 'left': '', 'right': '' }

let g:lightline.tab_component_function = {
      \ 'filename': 'lightline#tab#filename',
      \ 'modified': 'LightlineModified',
      \ 'readonly': 'lightline#tab#readonly',
      \ 'tabnum': 'lightline#tab#tabnum' }
