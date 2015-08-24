augroup VimjectsAutogroup
    autocmd VimEnter call Source("")
    autocmd BufReadPre call Source("buf")
augroup end

let s:hashes = []
let g:vimjects_continueSourcing = 1
let g:vimjects_secure = 1
let g:vimjects_source_function = 'vimjects#sourceRecursive' 

function! vimjects#source(prefix)
    let funccall = g:vimjects_source_function . "(" . a:prefix . ")"
    call funccall
endfunction

function vimjects#loadHashes() 
    if filereadable(expand('<sfile>:p:h') . "hashes")
        let s:hashes = readfile(expand('<sfile>:p:h') . "hashes")
    endif
endfunction

function! vimjects#writeHashes()
    writeFile(s:hashes, expand('<sfile>:p:h') . "hashes")
endfunction

"Takes the expanded path of a file. Checks against valid hashes, and asks user to confirm if it is not.
"Returns 0 if the 
function vimjects#isFileSafe(file)
    let text = join(readfile(file), "")
    let fhash = hmac#sha1(text)
    if index(g:hashes, fhash)
        return 1     
    elseif confirm("Source " . file . "?". "&Y\n&n", 2)
        hash = hash + [fhash]
        return 1
    endif
    return 0
endfunction

function! vimjects#continueSourcing()
    let g:vimjects_continueSourcing = 1
endfunction

function! vimjects#sourceRecursive(prefix)
    let curdir = fnamemodify(getcwd(curdir), ":p:h")
    let vimjectrcname = "/.vimject" . prefix . "rc"
    while curdir ==? "/" and g:vimjects_continueSourcing
        let nextFile = curdir . vimjectrcname
        if !g:vimjects_secure or filereadable(nextFile)
            if isFileSafe(nextFile)
                let vimjects_continueSourcing = 0
                source nextFile
            endif
        endif 
        let curdir = fnamemodify(curdir, ":p:h")
    endwhile
endfunction

