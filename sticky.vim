let g:StickyBasePath = '/tmp/'
let g:StickyPathPrefix = 'co3k-sticky-'
let g:StickyPathSuffix = '.txt'

highlight sticky_exists cterm=underline

nnoremap mo :call StickyOpen()<CR>
nnoremap ma :call StickyAdd()<CR>

autocmd BufRead * call StickyLoad()

function! StickyLoad()
    let g:StickyPath = join([g:StickyPathPrefix, substitute(expand('%:p'), '[/\\]', ':', 'g'), g:StickyPathSuffix], '')

    let value = ''
    if filereadable(g:StickyBasePath . g:StickyPath)
        let value = join(readfile(g:StickyBasePath . g:StickyPath), '')
    endif

    exe 'let g:StickyValue = [' . value . ']'

    let g:StickyIndex = {}

    let _k = 0
    while _k < len(g:StickyValue)
      let _v = g:StickyValue[_k]
      call matchadd('sticky_exists', '\%'._v['line'].'l')

      if !has_key(g:StickyIndex, _v['line'])
        let g:StickyIndex[_v['line']] = []
      endif

      call add(g:StickyIndex[_v['line']], _k)

      let _k += 1
    endwhile
endfunction

function! StickyAdd()
    let s = input("Add Sticky: ")
    echo ""
    if "" != s
      let fname = g:StickyBasePath . g:StickyPath
      let b = []
      if filereadable(fname)
          let b = readfile(fname)
      endif
      call add(b, '{ "body": "' . s . '", "line": ' . line('.') . ' },')
      call writefile(b, fname)

      call StickyLoad()
      call StickyOpen()
    endif
endfunction

function! StickyOpen()
    let _l = line('.')
    if has_key(g:StickyIndex, _l)
        for _e in g:StickyIndex[_l]
            echo g:StickyValue[_e]['body']
        endfor
    endif
endfunction
