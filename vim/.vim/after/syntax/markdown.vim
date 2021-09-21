set spell
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

set expandtab

set colorcolumn=81

function! HighlightMath()
    " Block math. Look for "$$[anything]$$"
    syn region math_block start=/\$\$/ end=/\$\$/
    " inline math. Look for "$[not $][anything]$"
    syn match math '\$[^$].\{-}\$'

    "" Actually highlight those regions.
    hi link math Statement
    hi link math_block Function
endfunction
call HighlightMath()

