augroup VimjectsAutogroup
    au BufNewFile,BufRead .vimjectrc* setlocal ft=vim
    autocmd VimEnter call vimjects#source("")
    autocmd BufReadPre call vimjects#source("buf")
augroup end

let s:knownfiles = {}
let s:vimjects_continueSourcing = 1

let g:vimjects_secure = 1 "If vimjects should run in sanity-checking mode.
let g:vimjects_source_function = 'vimjects#sourceRecursive' "Function used to source vimjects files. May be customized by user.

function! vimjects#source(prefix)
    if len(s:knownfiles) == 0
        call vimjects#loadKnownFiles()
    endif 
    let funccall = "call "  . g:vimjects_source_function . '("' . a:prefix . '")'
    execute funccall
endfunction

function! vimjects#loadKnownFiles() 
    if filereadable(expand('<sfile>:p:h') . "/hashes")
        let text = readfile(expand('<sfile>:p:h') . "/hashes")
        let s:knownfiles = eval("{".join(text)."}")
    endif
endfunction

"Adds a good file to the dictionary and then writes it to the file
function! vimjects#addKnownFiles(filename, hash)
    let s:knownfiles[a:filename] = a:hash
    let liKnownFiles = []
    for item in items(s:knownfiles)
        let liKnownFiles = liKnownFiles + [string(item[0]) . ":" . string(item[1]) . ","]
    endfor 
    call writefile(liKnownFiles, expand('<sfile>:p:h') . "/hashes")
endfunction

"Takes the expanded path of a file. Checks against valid hashes, and asks user to confirm if it is not found
"or if the file is modified.
function! vimjects#isFileSafe(filename)
    let hash = len(join(readfile(a:filename)))
    if has_key(s:knownfiles, hash) && s:knownfiles[a:filename] == hash
        return 1
    elseif has_key(s:knownfiles, hash) && confirm("File " . a:filename . "has changed since last sourced. Continue sourcing?", "&Yes\n&no", 2) == 1
        call vimjects#addKnownFiles(a:filename, hash)
        return 1
    elseif confirm("Source unknown file" . a:filename . "?", "&Yes\n&no", 2) == 1
        call vimjects#addKnownFiles(a:filename, hash)
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
        if filereadable(nextFile) && (!g:vimjects_secure || vimjects#isFileSafe(nextFile))
            let s:vimjects_continueSourcing = 0
            execute "source " . l:nextFile
        endif 
        let curdir = fnamemodify(curdir, ":p:h:h")
    endwhile
endfunction
