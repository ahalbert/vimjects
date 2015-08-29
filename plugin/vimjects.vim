augroup VimjectsAutogroup
    au!
    autocmd BufNewFile,BufRead .vimjectrc* setlocal ft=vim
    autocmd VimEnter * call vimjects#source()
    autocmd BufReadPre * call vimjects#source()
augroup end

let s:continueSourcing = 1
let s:globalsource = 1
let s:knownfiles = {}

let g:Vimjects_secure = 1 "If vimjects should run in sanity-checking mode.
let g:Vimjects_source_function = 'vimjects#sourceRecursive' "Function used to source vimjects files. May be customized by user.
let g:Vimjects_sourceall = 0 "Is vimjects#continueSourcing needed?

function! vimjects#source(...)
    if g:Vimjects_source_function ==? ""
        return
    endif
    let s:vimjects_continueSourcing = 1
    if len(s:knownfiles) == 0
        call vimjects#loadKnownFiles()
    endif 
    let funccall = "let s:sourcefiles = "  . g:Vimjects_source_function . '(' . "a:000" . ')'
    execute funccall
    for l:filename in s:sourcefiles
            if !g:Vimjects_secure
                call vimjects#safeSourceFile(l:filename)
            else
                let s:vimjects_continueSourcing = 0
                execute "source " . a:filename
            endif
        if !g:Vimjects_sourceall && !s:continueSourcing 
            break
        endif
    endfor
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
function! vimjects#safeSourceFile(filename)
    let hash = len(join(readfile(a:filename)))
    if has_key(s:knownfiles, a:filename) 
        if s:knownfiles[a:filename] != hash && 
        \  confirm("File " . a:filename . " has changed since last sourced. Continue sourcing?", "&Yes\n&no", 2) == 2
            return 0
        endif
    else   
        if confirm("Source unknown file " . a:filename . " ?", "&Yes\n&no", 2) == 2
            return 0
        endif
    endif
    call vimjects#addKnownFiles(a:filename, hash)
    let s:vimjects_continueSourcing = 0
    execute "source " . a:filename
    return 1
endfunction

function! vimjects#continueSourcing()
    let s:continueSourcing = 1
endfunction

function! vimjects#reglobalsouce()
    let s:globalsource = 1
endfunction

function! vimjects#sourceRecursive(...)
    let sourcefiles = []
    if s:globalsource
        let prefix = ""
        let s:globalsource = 0
    else
        let prefix = "buf"
    endif
    let curdir = fnamemodify(getcwd(), ":p:h")
    let vimjectrcname = "/.vimject" . "rc" . l:prefix
    while curdir !=? "/" 
        let nextFile = curdir . vimjectrcname
        if filereadable(nextFile) 
            call add(sourcefiles, nextFile)
        endif 
        let curdir = fnamemodify(curdir, ":p:h:h")
    endwhile
    return sourcefiles
endfunction
