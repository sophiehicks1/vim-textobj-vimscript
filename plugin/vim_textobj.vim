" Text objects: Vimscript blocks (split into two)
"   v: non-function control structures
"      - if ... elseif/else ... endif
"      - for ... endfor
"      - while ... endwhile
"      - try ... catch/finally ... endtry
"      - augroup <name> ... augroup END
"   f: functions
"      - function / function! ... endfunction
"
" Behavior:
"   - Linewise selection
"   - Robust nesting
"   - Skips matches inside comments/strings (requires :syntax on)
"
" Requires: kana/vim-textobj-user
" Provides:
"   ac/ic - around/inner non-function block (linewise)
"   af/if - around/inner function block     (linewise)

if exists('g:loaded_textobj_vimscript_blocks')
  finish
endif
let g:loaded_textobj_vimscript_blocks = 1

" -------------------------------------------------------------------
" Pair definitions per block type (anchored at BOL, allow optional leading ':')
let s:PAIR_DEFS = {
\ 'if': {
\   'start': '^\s*\%(:\s*\)\?if\>',
\   'middle': '^\s*\%(:\s*\)\?\%(else\|elseif\)\>',
\   'end': '^\s*\%(:\s*\)\?endif\>',
\ },
\ 'for': {
\   'start': '^\s*\%(:\s*\)\?for\>',
\   'middle': '',
\   'end': '^\s*\%(:\s*\)\?endfor\>',
\ },
\ 'while': {
\   'start': '^\s*\%(:\s*\)\?while\>',
\   'middle': '',
\   'end': '^\s*\%(:\s*\)\?endwhile\>',
\ },
\ 'try': {
\   'start': '^\s*\%(:\s*\)\?try\>',
\   'middle': '^\s*\%(:\s*\)\?\%(catch\|finally\)\>',
\   'end': '^\s*\%(:\s*\)\?endtry\>',
\ },
\ 'augroup': {
\   'start': '^\s*\%(:\s*\)\?augroup\>\s\+\%(END\>\)\@!',
\   'middle': '',
\   'end': '^\s*\%(:\s*\)\?augroup\>\s\+END\>',
\ },
\ 'function': {
\   'start': '^\s*\%(:\s*\)\?function!\?\>',
\   'middle': '',
\   'end': '^\s*\%(:\s*\)\?endfunction\>',
\ },
\}

let s:GENERAL_TYPES = ['if', 'for', 'while', 'try', 'augroup']
let s:FUNC_TYPES    = ['function']

function! s:is_comment_or_string_at(lnum, col) abort
  if !exists('*synID') || !exists('*synIDattr')
    return getline(a:lnum) =~# '^\s*"'
  endif
  let name = synIDattr(synID(a:lnum, a:col, 1), 'name')
  return name =~? 'comment\|string'
endfunction

function! s:skip_comments_strings() abort
  if !exists('*synID') || !exists('*synIDattr')
    return 0
  endif
  let name = synIDattr(synID(line('.'), col('.'), 1), 'name')
  return name =~? 'comment\|string'
endfunction

function! s:_build_start_union(types) abort
  let pats = map(copy(a:types), {_, t -> s:PAIR_DEFS[t].start})
  return '\%(' . join(pats, '\|') . '\)'
endfunction

function! s:_detect_type_at(lnum, types) abort
  let l = getline(a:lnum)
  for t in a:types
    if l =~# s:PAIR_DEFS[t].start
      return t
    endif
  endfor
  return ''
endfunction

" Find nearest start among the provided types, skipping comments/strings.
" Returns [lnum, col, type] or [0, 0, ''] if not found.
function! s:find_block_start_pos_for(types) abort
  let view = winsaveview()
  try
    let start_re = s:_build_start_union(a:types)
    while 1
      let pos = searchpos(start_re, 'bnW')
      if pos ==# [0, 0]
        return [0, 0, '']
      endif
      if !s:is_comment_or_string_at(pos[0], pos[1])
        let t = s:_detect_type_at(pos[0], a:types)
        if !empty(t)
          return [pos[0], pos[1], t]
        endif
      endif
      call cursor(pos[0], max([1, pos[1] - 1]))
    endwhile
  finally
    call winrestview(view)
  endtry
endfunction

" Find matching end for a given start and type using searchpairpos()
" Returns [lnum, col] or [0, 0].
function! s:find_block_end_pos_for(start_pos, type) abort
  if a:start_pos[0] == 0
    return [0, 0]
  endif
  let view = winsaveview()
  try
    call cursor(a:start_pos[0], a:start_pos[1])
    let S = s:PAIR_DEFS[a:type].start
    let M = s:PAIR_DEFS[a:type].middle
    let E = s:PAIR_DEFS[a:type].end
    return searchpairpos(S, M, E, 'nW', 's:skip_comments_strings()')
  finally
    call winrestview(view)
  endtry
endfunction

function! s:get_bounds_linewise_for(types) abort
  let s_pos = s:find_block_start_pos_for(a:types)
  if s_pos[0] == 0
    return []
  endif
  let e_pos = s:find_block_end_pos_for(s_pos, s_pos[2])
  if e_pos ==# [0, 0]
    return []
  endif
  let s_lnum = s_pos[0]
  let e_lnum = e_pos[0]
  let s_col = 1
  let e_col = strlen(getline(e_lnum)) + 1
  return [s_lnum, s_col, e_lnum, e_col]
endfunction

" Public selectors for non-function blocks (key: v)
function! TextobjVimBlocksSelectA(...) abort
  let b = s:get_bounds_linewise_for(s:GENERAL_TYPES)
  if empty(b)
    return 0
  endif
  return ['V', [b[0], b[1]], [b[2], b[3]]]
endfunction

function! TextobjVimBlocksSelectI(...) abort
  let b = s:get_bounds_linewise_for(s:GENERAL_TYPES)
  if empty(b)
    return 0
  endif
  let s_l = b[0]
  let e_l = b[2]
  if e_l - s_l <= 1
    return ['V', [b[0], b[1]], [b[2], b[3]]]
  endif
  return ['V', [s_l + 1, 1], [e_l - 1, strlen(getline(e_l - 1)) + 1]]
endfunction

" Public selectors for function blocks (key: f)
function! TextobjVimFuncSelectA(...) abort
  let b = s:get_bounds_linewise_for(s:FUNC_TYPES)
  if empty(b)
    return 0
  endif
  return ['V', [b[0], b[1]], [b[2], b[3]]]
endfunction

function! TextobjVimFuncSelectI(...) abort
  let b = s:get_bounds_linewise_for(s:FUNC_TYPES)
  if empty(b)
    return 0
  endif
  let s_l = b[0]
  let e_l = b[2]
  if e_l - s_l <= 1
    return ['V', [b[0], b[1]], [b[2], b[3]]]
  endif
  return ['V', [s_l + 1, 1], [e_l - 1, strlen(getline(e_l - 1)) + 1]]
endfunction

" Register with vim-textobj-user:
" - 'v' = non-function blocks => ac/ic
" - 'f' = functions          => af/if
if exists('*textobj#user#plugin')
  call textobj#user#plugin('vimscriptblock', {
  \ 'c': {
  \   'select-a-function': 'TextobjVimBlocksSelectA',
  \   'select-i-function': 'TextobjVimBlocksSelectI',
  \   'select-a': [],
  \   'select-i': [],
  \ },
  \ 'f': {
  \   'select-a-function': 'TextobjVimFuncSelectA',
  \   'select-i-function': 'TextobjVimFuncSelectI',
  \   'select-a': [],
  \   'select-i': [],
  \ },
  \ })
endif

augroup vim_textobjs
  autocmd!
  autocmd FileType vim call textobj#user#map('vimscriptblock', {
        \ 'c': {
        \   'select-a': 'ac',
        \   'select-i': 'ic',
        \ },
        \ 'f': {
        \   'select-a': 'af',
        \   'select-i': 'if',
        \ },
        \ })
augroup END
