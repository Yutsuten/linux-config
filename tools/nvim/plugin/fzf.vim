scriptencoding utf-8

" Commands
command -nargs=? -complete=dir Find call s:Find(<f-args>)
command -nargs=0 Project call s:Project()

" Shortcuts
nnoremap <silent> <leader>m :Find<CR>
nnoremap <silent> <leader>M :Find %:p:h<CR>
nnoremap <silent> <leader>p :tabnew +Project<CR>

" Script
let s:projects_dir = $HOME .. '/Projects'

function s:Find(...) abort
  let s:find_dir = './'
  if a:0
    let s:find_dir = fnamemodify(a:1, ':p')
  endif
  let blacklist = [
  \   '-name .git',
  \   '-name node_modules',
  \   '-name __pycache__',
  \ ]
  call s:Fzf('find ' .. s:find_dir .. ' -type d \( ' .. join(blacklist, ' -o ') .. ' \) -prune -o -type f -printf "%P\n"', function('s:FindSelected'))
endfunction

function s:FindSelected(selection) abort
  execute 'edit ' .. s:find_dir .. a:selection
endfunction

function s:Project() abort
  call s:Fzf('printf "%s\n" ' .. s:projects_dir .. '/* | xargs --delimiter "\n" --max-args 1 basename', function('s:ProjectSelected'))
endfunction

function s:ProjectSelected(selection) abort
  execute 'tcd ' .. s:projects_dir .. '/' .. a:selection
  if filereadable('Session.vim')
    source Session.vim
  else
    enew
  endif
endfunction

function s:Fzf(input_cmd, on_selected) abort
  if exists('s:curbuf_nr')
    echo 'Only one fzf instance can be opened at a time'
    return
  endif

  let s:curbuf_nr = 0
  if strlen(expand('%:~:.'))
    let s:curbuf_nr = bufnr()
  endif

  let s:tmpfile = tempname()
  let cmd = a:input_cmd .. ' | fzf --layout=reverse > ' .. s:tmpfile

  let s:on_selected = a:on_selected
  enew | call termopen(['sh', '-c', cmd], {'on_exit': function('s:OnExit')})
  let s:tmpbuf_nr = bufnr()
endfunction

function s:OnExit(job_id, exit_code, event_type) abort
  let selection = []
  if filereadable(s:tmpfile)
    let selection = readfile(s:tmpfile)
    call delete(s:tmpfile)
  endif

  if !empty(selection)
    call s:on_selected(selection[0])
  elseif s:curbuf_nr && bufexists(s:curbuf_nr)
    execute 'buffer ' .. s:curbuf_nr
  elseif !(tabpagenr('$') > 1 && tabpagewinnr(tabpagenr(), '$') == 1)
    enew
  endif

  if bufexists(s:tmpbuf_nr)
    execute 'bdelete ' .. s:tmpbuf_nr
  endif

  unlet s:curbuf_nr s:tmpfile s:tmpbuf_nr s:on_selected
  if exists('s:find_dir')
    unlet s:find_dir
  endif
endfunction
