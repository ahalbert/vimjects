augroup VimjectsAutogroup
    autocmd VimEnter call vimjects#source("")
    autocmd BufReadPre call vimjects#source("buf")
augroup end

let s:goodfiles = []
let s:vimjects_continueSourcing = 1
let g:vimjects_secure = 1
let g:vimjects_source_function = 'vimjects#sourceRecursive' 

function! vimjects#source(prefix)
    if len(s:goodfiles) == 0
        call vimjects#loadGoodFiles()
    endif 
    let funccall = "call "  . g:vimjects_source_function . '("' . a:prefix . '")'
    execute funccall
endfunction

function! vimjects#loadGoodFiles() 
    if filereadable(expand('<sfile>:p:h') . "hashes")
        let s:hashes = readfile(expand('<sfile>:p:h') . "hashes")
    endif
endfunction

function! vimjects#writeGoodFiles()
    writeFile(s:hashes, expand('<sfile>:p:h') . "hashes")
endfunction

"Takes the expanded path of a file. Checks against valid hashes, and asks user to confirm if it is not.
"Returns 0 if the 
function! vimjects#isFileSafe(filename)
    if index(s:goodfiles, a:filename)
        return 1     
    elseif confirm("Source " . a:file . "?". "&Y\n&n", 2)
        let s:goodfiles = s:goodfiles + [a:filename]
        return 1
    endif
    return 0
endfunction

function! vimjects#continueSourcing()
    let s:vimjects_continueSourcing = 1
endfunction

function! vimjects#sourceRecursive(prefix)
    let s:vimjects_continueSourcing = 1
    let curdir = fnamemodify(getcwd(), ":p:h")
    let vimjectrcname = "/.vimject" . a:prefix . "rc"
    while curdir !=? "/" && s:vimjects_continueSourcing
        let nextFile = curdir . vimjectrcname
        echo nextFile
        if filereadable(nextFile) || (!g:vimjects_secure && vimjects#isFileSafe(nextFile))
            let s:vimjects_continueSourcing = 0
            execute "source " . l:nextFile
        endif 
        let curdir = fnamemodify(curdir, ":p:h:h")
    endwhile
endfunction

