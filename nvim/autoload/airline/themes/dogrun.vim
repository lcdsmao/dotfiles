let s:save_cpo = &cpo
set cpo&vim

function! s:build_palette() abort
  let col_base     = ['#4b4e6d', '#282a3a', 60, 235]
  let col_edge     = ['#222433', '#929be5', 235, 104]
  let col_error    = ['#282a3a', '#f56574', 235, 204]
  let col_gradient = ['#4b4e6d', '#282a3a', 60, 235]
  let col_nc       = ['#4b4e6d', '#282a3a', 60, 235]
  let col_warning  = ['#222433', '#c2968c', 235, 138]
  let col_insert   = ['#222433', '#73c1a9', 235, 79]
  let col_replace  = ['#222433', '#f56574', 235, 204]
  let col_visual   = ['#222433', '#c173c1', 235, 170]
  let col_red      = ['#f56574', '#282a3a', 204, 235]

  let p = {}
  let p.inactive = airline#themes#generate_color_map(
        \ col_nc,
        \ col_nc,
        \ col_nc)
  let p.normal = airline#themes#generate_color_map(
        \ col_edge,
        \ col_gradient,
        \ col_base)
  let p.insert = airline#themes#generate_color_map(
        \ col_insert,
        \ col_gradient,
        \ col_base)
  let p.replace = airline#themes#generate_color_map(
        \ col_replace,
        \ col_gradient,
        \ col_base)
  let p.visual = airline#themes#generate_color_map(
        \ col_visual,
        \ col_gradient,
        \ col_base)
  let p.terminal = airline#themes#generate_color_map(
        \ col_insert,
        \ col_gradient,
        \ col_base)

  " Accents
  let p.accents = {
        \   'red': col_red,
        \ }

  " Error
  let p.inactive.airline_error = col_error
  let p.insert.airline_error = col_error
  let p.normal.airline_error = col_error
  let p.replace.airline_error = col_error
  let p.visual.airline_error = col_error

  " Warning
  let p.inactive.airline_warning = col_warning
  let p.insert.airline_warning = col_warning
  let p.normal.airline_warning = col_warning
  let p.replace.airline_warning = col_warning
  let p.visual.airline_warning = col_warning

  " Terminal
  let p.normal.airline_term = col_base
  let p.terminal.airline_term = col_base
  let p.visual.airline_term = col_base

  return p
endfunction


let g:airline#themes#dogrun#palette = s:build_palette()


let &cpo = s:save_cpo
unlet s:save_cpo
