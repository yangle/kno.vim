function! Kno(raw)
    let tokens = s:Tokenize(a:raw)
    if len(tokens) == 0
        return
    endif

    " search for files that contain all tokens
    " https://stackoverflow.com/a/44754369
    let query = "(?s)"
    for token in tokens
        let query = query . "(?=.*" . substitute(token, " ", '\\s+', "g") . ")"
    endfor
    let query = query . '.*?\\n\\K(?-s).*' . substitute(tokens[0], " ", '\\s+', "g")

    let ignore_case = (a:raw !~# '[A-Z]')  " smartcase
    call s:Search('"' . escape(query, '"') . '"', ignore_case)

    " open quickfix window
    botright copen
    redraw!

    " highlight tokens individually
    let query_vim = []
    for token in tokens
        call add(query_vim, substitute(token, " ", '\\_s\\+', "g"))
    endfor
    let @/ = join(query_vim, '\|') . (ignore_case ? '\c' : '')
    call feedkeys(":let &hlsearch=1 \| echo \<CR>", "n")
endfunction

" poor man's shlex.split
function! s:Tokenize(raw)
    let tokens = []
    let raw = split(a:raw, ' ')
    let idx = 0

    while idx < len(raw)
        if raw[idx][0] !~ '"\|'''
            call add(tokens, raw[idx])
        else
            let begin = idx
            let sep = raw[idx][0]
            while idx < len(raw) && raw[idx] !~ sep.'$'
                let idx += 1
            endwhile

            let token = join(raw[begin:idx], " ")

            " remove quotation marks and strip excessive spaces
            let token = token[1: ((idx < len(raw)) ? (-2) : (-1))]
            let token = substitute(token, '^\s*\(.\{-}\)\s*$', '\1', '')
            let token = substitute(token, '\s+', " ", "g")

            call add(tokens, token)
        endif

        let idx += 1
    endwhile

    return tokens
endfunction

function! s:Search(query, ignore_case)
    let grepformat_ = &grepformat
    try
        let &l:grepprg  = 'ag --vimgrep --silent -m1' " only the first match
        if a:ignore_case
            let &l:grepprg = &l:grepprg . " -i"
        endif
        let &grepformat = '%f:%l:%c:%m,%f:%l:%m'

        echo "Searching ..."
        silent execute "grep" a:query
    finally
        let &grepformat = l:grepformat_
    endtry
endfunction

command! -bang -nargs=* Kno call Kno(<q-args>)
cnoreabbrev K Kno
