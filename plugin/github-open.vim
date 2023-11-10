if exists('g:loaded_github_open_plugin') && g:loaded_github_open_plugin
 finish
endif

function! s:setGitHubOpenCommand()
  let l:uname = toupper(system('uname'))
  if l:uname =~# 'LINUX' || l:uname =~# 'BSD'
    let g:github_open_command = 'xdg-open'
  elseif l:uname =~# 'DARWIN'
    let g:github_open_command = 'open'
  else
    let g:github_open_command = 'open'
  endif
endfunction

if !exists('g:github_open_command')
  call s:setGitHubOpenCommand()
endif

if !executable('git') || !executable(g:github_open_command)
  finish
endif

function! s:LogError(msg)
  echoerr '[ERROR] vim-github-open: ' . a:msg
endfunction

function! s:gitRemoteUrl()
  return substitute(system(join(['git', 'remote', 'get-url', 'origin'], ' ')), '\n$', '', '')
endfunction

function! s:gitSymbolicRef()
  return substitute(system(join(['git', 'symbolic-ref', '--short', '-q', 'HEAD'], ' ')), '\n$', '', '')
endfunction

function! s:gitHashRef()
  return substitute(system(join(['git', 'rev-parse', 'HEAD'], ' ')), '\n$', '', '')
endfunction

function! s:gitListFile(path)
  return substitute(system(join(['git', 'ls-files', '--full-name', a:path], ' ')), '\n$', '', '')
endfunction

function! s:github_openGitHubFileURL(file_path, lines)
  let l:ref = s:gitSymbolicRef()
  if empty(l:ref) | let l:ref = s:gitHashRef() | endif
  let l:repo_url = substitute(s:gitRemoteUrl(), '\.git\n*$', '', '')
  if empty(l:repo_url) | call s:LogError('failed get git repository remote url') | return | endif
  if a:lines[0]
    if a:lines[1] ==# a:lines[2]
      return l:repo_url . '/blob/' . l:ref . '/' . a:file_path . '#L' . a:lines[1]
    else
      return l:repo_url . '/blob/' . l:ref . '/' . a:file_path . '#L' . a:lines[1] . ',L' . a:lines[2]
    endif
  elseif a:lines[0] > 0
    return l:repo_url . '/blob/' . l:ref . '/' . a:file_path . '#L' . a:lines[1]
  else
    return l:repo_url . '/blob/' . l:ref . '/' . a:file_path
  endif
endfunction

function! s:runOpenGitHubFileLine(...)
  let file_path = expand('%:p')
  let l:github_file = s:gitListFile(l:file_path)
  if empty(l:github_file) | call s:LogError('file does not belong to a git repository') | return | endif
  let l:url = s:github_openGitHubFileURL(l:github_file, a:)
  if empty(l:url) | return | endif
  call system(join([g:github_open_command, l:url], ' '))
endfunction

command! -range OpenGitHubFile call s:runOpenGitHubFileLine()
command! -range OpenGitHubFileLine call s:runOpenGitHubFileLine(<line1>,<line2>)

let g:loaded_github_open_plugin = 1
