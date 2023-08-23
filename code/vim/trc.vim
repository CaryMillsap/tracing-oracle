" MacVim Syntax Highlighting for Oracle .trc files
" Cary Millsap



" Comments (lines whose first non-blank character is #)
syntax match trcComment "^\s*#.*$"
highlight link trcComment Comment

" Numbers (matches whole numbers)
syntax match trcNumber "\<\d\+\>"
highlight link trcNumber Number

" Database calls
syntax match trcDbcall "PARSE\|EXEC\|FETCH"
highlight link trcDbcall Identifier

" System calls
syntax match trcSyscall ": nam='.*'"hs=s+7,he=e-1
highlight link trcSyscall Identifier

" Cursor ID
syntax match trcCursorID "\<\#\d\+\>"
highlight link trcCursorID Identifier


" #TODO
"
" To test this:
" - Put a copy of this file (or a symlink) in ~/.vim/syntax.
" - ":set filetype=trc" in the test .trc file.
"
" CursorID RE doesn't match yet.
" ^PARSING IN CURSOR.*END OF STMT$ should be formatted like a constant.
" Diminish the color of WAIT.
"
" https://superuser.com/questions/844004/creating-a-simple-vim-syntax-highlighting
"
"

