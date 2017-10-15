function! Kno(args)
    let args = escape(a:args, '|#%')

    let tokens = split(args, ',')  " for now
    let query = "(?s)"
    let hlquery = []
    for token in tokens
        let query = query . "(?=.*" . substitute(token, " ", '\\s+', "g") . ")"
        call add(hlquery, substitute(token, " ", '\\_s\\+', "g"))
    endfor
    if len(tokens) > 0
        let query = query . '.*?\\n\\K(?-s).*' . substitute(tokens[0], " ", '\\s+', "g")
    endif

    " search and show the quickfix window
    call s:Search(query)
    botright copen
    redraw!

    " highlight the search query
    let @/ = join(hlquery, '\|')
    call feedkeys(":let &hlsearch=1 \| echo \<CR>", "n")
endfunction

function! s:Search(query)
    let grepformat_ = &grepformat
    try
        let &l:grepprg  = 'ag --vimgrep --silent -m1' " only the first match
        let &grepformat = '%f:%l:%c:%m,%f:%l:%m'

        echo "Searching ..."
        silent execute "grep" '"'.a:query.'"'
    finally
        let &grepformat = l:grepformat_
    endtry
endfunction

command! -bang -nargs=* Kno call Kno(<q-args>)
cnoreabbrev K Kno
