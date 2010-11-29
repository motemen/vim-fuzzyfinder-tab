" Add line below in your .vimrc.
" autocmd VimEnter * call fuf#addMode('tab')

"=============================================================================
" SETTINGS {{{1
call l9#defineVariableDefault('g:fuf_tab_prompt', '>Tab[]>')
call l9#defineVariableDefault('g:fuf_tab_format_item_line', 'fuf#tab#formatItemLine')
" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function! fuf#tab#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function! fuf#tab#getSwitchOrder()
  return g:fuf_buffer_switchOrder
endfunction

"
function! fuf#tab#getEditableDataNames()
  return []
endfunction

"
function! fuf#tab#renewCache()
endfunction

"
function! fuf#tab#requiresOnCommandPre()
  return 0
endfunction

"
function! fuf#tab#onInit()
  call fuf#defineLaunchCommand('FufTab', s:MODE_NAME, '""', [])
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

"
function! fuf#tab#formatItemLine(nr)
  let tab_cwd = gettabvar(a:nr, 'cwd')

  let bufs = []
  for bufnr in tabpagebuflist(a:nr)
    if getbufvar(bufnr, '&filetype') == 'fuf'
      continue
    endif

    let bufname = fnamemodify(bufname(bufnr), ':t')
    call add(bufs, empty(bufname) ? '[Scratch]' : bufname)
    if empty(tab_cwd)
      let tab_cwd = getbufvar(bufnr, 'cwd')
    endif
  endfor

  return '[' . a:nr . '] ' . join(bufs, ' ') . ' (' . tab_cwd . ')'
endfunction

"
function! s:makeItem(nr)
  let item = fuf#makeNonPathItem(function(g:fuf_tab_format_item_line)(a:nr), '')
  let item.index = a:nr
  let item.tabNr = a:nr
  return item
endfunction

"
function! s:compareTimeDescending(i1, i2)
  return a:i1.time == a:i2.time ? 0 : a:i1.time > a:i2.time ? -1 : +1
endfunction

"
function! s:findItem(items, word)
  for item in a:items
    if item.word ==# a:word
      return item
    endif
  endfor
  return {}
endfunction

" }}}1
"=============================================================================
" s:handler {{{1

let s:handler = {}

"
function! s:handler.getModeName()
  return s:MODE_NAME
endfunction

"
function! s:handler.getPrompt()
  return fuf#formatPrompt(g:fuf_tab_prompt, self.partialMatching, '')
endfunction

"
function! s:handler.getPreviewHeight()
  return g:fuf_previewHeight
endfunction

"
function! s:handler.isOpenable(enteredPattern)
  return 1
endfunction

"
function! s:handler.makePatternSet(patternBase)
  return fuf#makePatternSet(a:patternBase, 's:interpretPrimaryPatternForNonPath',
        \                   self.partialMatching)
endfunction

"
function! s:handler.makePreviewLines(word, count)
  let item = s:findItem(self.items, a:word)
  if empty(item)
    return []
  endif
  return fuf#makePreviewLinesForFile(item.bufNr, a:count, self.getPreviewHeight())
endfunction

"
function! s:handler.getCompleteItems(patternPrimary)
  return self.items
endfunction

"
function! s:handler.onOpen(word, mode)
  let item = s:findItem(self.items, a:word)
  if empty(item)
    " do nothing
  else
    execute 'tabnext' item.tabNr
  endif
endfunction

"
function! s:handler.onModeEnterPre()
endfunction

"
function! s:handler.onModeEnterPost()
  let self.items = range(1, tabpagenr('$'))
  call map(self.items, 's:makeItem(v:val)')
endfunction

"
function! s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
