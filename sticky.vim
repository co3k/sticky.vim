let g:StickyBasePath = '/tmp/'
let g:StickyPathPrefix = 'co3k-sticky-'
let g:StickyPathSuffix = '.txt'

let g:StickyMatches = []

highlight sticky_exists cterm=underline

nnoremap mo :call StickyOpen()<CR>
nnoremap ma :call StickyAdd()<CR>
nnoremap mc :call StickyClear()<CR>
nnoremap ml :call StickyList()<CR>

autocmd BufRead * call StickyLoad()

function! StickyClear()
    if filereadable(g:StickyFullPath)
        call writefile([], g:StickyFullPath)
    endif

    call StickyLoad()
endfunction

function! CompareLineNumber(i1, i2)
    return str2nr(a:i1) - str2nr(a:i2)
endfunction

function! StickyList()
    let lines = {}

    for _e in g:StickyValue
        let line = _e['line'] . ":\t" . getline(_e['line'])
        if has_key(lines, _e['line'])
            let line = lines[_e['line']]
        endif

        let lines[_e['line']] = line . "\n" . _e['body']
    endfor

    for key in sort(keys(lines), "CompareLineNumber")
        echo lines[key] . "\n------------------"
    endfor
endfunction

function! ClearStickyMatches()
    for _m in g:StickyMatches
        call matchdelete(_m)
    endfor

    let g:StickyMatches = []
endfunction

function! StickyLoad()
    call ClearStickyMatches()

    let g:StickyPath = join([g:StickyPathPrefix, substitute(resolve(expand('%:p')), '[/\\]', ':', 'g'), g:StickyPathSuffix], '')
    let g:StickyFullPath = g:StickyBasePath . g:StickyPath

    let value = ''
    if filereadable(g:StickyFullPath)
        let value = join(readfile(g:StickyFullPath), '')
    endif

    exe 'let g:StickyValue = [' . value . ']'

    let g:StickyIndex = {}

    let _k = 0
    while _k < len(g:StickyValue)
      let _v = g:StickyValue[_k]
      let _m = matchadd('sticky_exists', '\%'._v['line'].'l')
      call add(g:StickyMatches, _m)

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
      let b = []
      if filereadable(g:StickyFullPath)
          let b = readfile(g:StickyFullPath)
      endif
      call add(b, '{ "body": "' . escape(s, '"') . '", "line": ' . line('.') . ' },')
      call writefile(b, g:StickyFullPath)

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
