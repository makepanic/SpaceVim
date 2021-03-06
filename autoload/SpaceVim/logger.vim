let s:logger_level = g:spacevim_debug_level
let s:levels = ['Info', 'Warn', 'Error']
let s:logger_file = expand('~/.SpaceVim/.SpaceVim.log')
let s:log_temp = []

""
" @public
" Set debug level of SpaceVim, by default it is 1. all message will be logged.
"
"     1 : log all the message.
"
"     2 : log warning and error message
"
"     3 : log error message only
function! SpaceVim#logger#setLevel(level) abort
    let s:logger_level = a:level
endfunction

function! SpaceVim#logger#info(msg) abort
    if g:spacevim_enable_debug && s:logger_level <= 1
        call s:wite(s:warpMsg(a:msg, 1))
    else
        call add(s:log_temp,s:warpMsg(a:msg,1))
    endif
endfunction

function! SpaceVim#logger#warn(msg) abort
    if g:spacevim_enable_debug && s:logger_level <= 2
        call s:wite(s:warpMsg(a:msg, 2))
    else
        call add(s:log_temp,s:warpMsg(a:msg,2))
    endif
endfunction

function! SpaceVim#logger#error(msg) abort
    if g:spacevim_enable_debug && s:logger_level <= 3
        call s:wite(s:warpMsg(a:msg, 3))
    else
        call add(s:log_temp,s:warpMsg(a:msg,3))
    endif
endfunction

function! s:wite(msg) abort
    let flags = filewritable(s:logger_file) ? 'a' : ''
    call writefile([a:msg], s:logger_file, flags)
endfunction


function! SpaceVim#logger#viewLog(...) abort
    let info = "SpaceVim Options :\n\n"
    let info .= join(SpaceVim#options#list(), "\n")
    let info .= "\n"

    let l = a:0 > 0 ? a:1 : 1
    if filereadable(s:logger_file)
        let logs = readfile(s:logger_file, '')
        return info . join(filter(logs, "v:val =~# '\[ SpaceVim \] \[\d\d\:\d\d\:\d\d\] \[" . s:levels[l] . "\]'"), "\n")
    else
        let info .= '[ SpaceVim ] : logger file ' . s:logger_file . ' does not exists, only log for current process will be shown!'
        let info .= join(filter(s:log_temp, "v:val =~# '\[ SpaceVim \] \[\d\d\:\d\d\:\d\d\] \[" . s:levels[l] . "\]'"), "\n")
        return  info
    endif
endfunction

""
" @public
" Set log output file of SpaceVim. by default it is
" `~/.SpaceVim/.SpaceVim.log`
function! SpaceVim#logger#setOutput(file) abort
    let s:logger_file = a:file
endfunction

function! s:warpMsg(msg,l) abort
    let time = strftime('%H:%M:%S')
    let log = '[ SpaceVim ] [' . time . '] [' . s:levels[a:l - 1] . '] ' . a:msg
    return log
endfunction

function! SpaceVim#logger#echoWarn(msg) abort
    echohl WarningMsg
    echom s:warpMsg(a:msg, 1)
    echohl None
endfunction
