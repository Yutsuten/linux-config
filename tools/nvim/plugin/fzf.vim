scriptencoding utf-8

" Commands
command -nargs=0 Buffer call s:Buffer()
command -nargs=? -complete=dir Find call s:Find(<f-args>)
command -nargs=0 Project call s:Project()

" Shortcuts
nnoremap <silent> <leader>b :Buffer<CR>
nnoremap <silent> <leader>m :Find<CR>
nnoremap <silent> <leader>M :Find %:p:h<CR>
nnoremap <silent> <leader>p :tabnew +Project<CR>

" Script
let s:projects_dir = $HOME .. '/Projects'

function s:Buffer() abort
  let buf_names = []
  for bufinfo in getbufinfo()
    call add(buf_names, fnamemodify(bufinfo['name'], ':~:.'))
  endfor
  if len(buf_names) == 0
    echo "Buffer list is empty"
    return
  endif
  let input_file = tempname()
  call writefile(buf_names, input_file)
  call s:Fzf(input_file, function('s:BufferSelected'))
endfunction

function s:BufferSelected(selection) abort
  execute 'buffer ' .. a:selection
endfunction

function s:Find(...) abort
  let s:find_dir = './'
  if a:0
    let s:find_dir = shellescape(fnamemodify(a:1, ':p'))
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

function s:Fzf(input, on_selected) abort
  if exists('s:curbuf_nr')
    echo 'Only one fzf instance can be opened at a time'
    return
  endif

  let s:curbuf_nr = 0
  if strlen(expand('%'))
    let s:curbuf_nr = bufnr()
  endif

  let s:tmpfile = tempname()
  let fzf_cmd = 'fzf --layout=reverse > ' .. s:tmpfile
  if filereadable(a:input)
    let cmd = fzf_cmd .. ' < ' .. a:input
    let s:input_file = a:input
  else
    let cmd = a:input .. ' | ' .. fzf_cmd
  endif

  let s:on_selected = a:on_selected
  enew | call termopen([$SHELL, '--command', cmd], {'on_exit': function('s:OnExit')})
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
  if exists('s:input_file')
    call delete(s:input_file)
    unlet s:input_file
  endif
endfunction
