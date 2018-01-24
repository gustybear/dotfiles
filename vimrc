let mapleader=',' " use comma for leader
scriptencoding utf-8

" Plugins {{{1
" Setup vim-plug manager {{{2
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Language Plugins {{{2
" RagTag: Mappings for XML/XHTML Editing {{{2
Plug 'tpope/vim-ragtag'

" Completion Plugins {{{2
" Deoplete: Dark Powered Asynchronous Completion Framework for Neovim/Vim8 {{{2
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Deoplete-Jedi: Deoplete Source for Python {{{2
Plug 'zchee/deoplete-jedi'
" UltiSnips: The ultimate snippet solution for Vim. {{{2
Plug 'SirVer/ultisnips'
" Vim-Snipmate: default snippets (Previously snipmate-snippets) {{{2
Plug 'honza/vim-snippets'

" Code Display Plugins {{{2
" Neoformat: A (Neo)vim plugin for formatting code {{{2
Plug 'sbdchd/neoformat'

" Integrations {{{2
" Fugitive: Git Wrapper for Vim {{{2
Plug 'tpope/vim-fugitive'
" Commentary: Commenting and Uncommenting {{{2
Plug 'tpope/vim-commentary'
" Dispatch: Enhanced Make for Build and Test {{{2
Plug 'tpope/vim-dispatch'
" Eunuch: Vim Sugar for the UNIX Shell Commands {{{2
Plug 'tpope/vim-eunuch'
" Tbone: Basic Tmux Support for Vim {{{2
Plug 'tpope/vim-tbone'
" Neomake: Asynchronous linting and make framework for Neovim/Vim {{{2
Plug 'neomake/neomake'
" Vinegar: combine with netrw to create a delicious salad dressing {{{2
Plug 'tpope/vim-vinegar'

" Interface {{{2
" Airline: Status/Tabline for Vim {{{2
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Fzf: A Command-Line Fuzzy Finder {{{2
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Gitgutter: Shows a Git Diff in the Gutter {{{2
Plug 'airblade/vim-gitgutter'

" Commands {{{2
" Surround: Mappings to Manipulate Parentheses {{{2
Plug 'tpope/vim-surround'
" Abolish: Fast Word Substitution {{{2
Plug 'tpope/vim-abolish'
" Repeat: '.' Operation That Supported Plugin Maps {{{2
Plug 'tpope/vim-repeat'
" Unimpaired: Bracket based mappings for Vim {{{2
Plug 'tpope/vim-unimpaired'
" Other {{{2
" Sensible: Vim Default Settings {{{2
Plug 'tpope/vim-sensible'
" Characterize: Print the Unicode Value of the Character Under the Cursor {{{2
Plug 'tpope/vim-characterize'
" Scriptease: Plugin to Write Vim Plugin {{{2
Plug 'tpope/vim-scriptease'
" Sleuth: Automatically Adjusts 'shiftwidth' and 'expandtab' {{{2
Plug 'tpope/vim-sleuth'
" Tabular: Align Text Based on Regular Expressions
Plug 'godlygeek/tabular'

" Transpose: Transpose matrices of text (swap lines with columns) {{{2
Plug 'salsifis/vim-transpose'

" Highlightedyank: Make the yanked region apparent {{{2
Plug 'machakann/vim-highlightedyank'

" Initialize plugin system {{{2
call plug#end()

" Plugin Configurations {{{1
" Language Plugin Configurations {{{2

" Completion Plugin Configurations {{{2
" Deoplete: Dark Powered Asynchronous Completion Framework for Neovim/Vim8 {{{2
let g:deoplete#enable_at_startup = 1
" UltiSnips: The ultimate snippet solution for Vim. {{{2
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" Code Display Plugins Configurations {{{2

" Integrations Plugin Configurations {{{2
" Neomake: Asynchronous linting and make framework for Neovim/Vim {{{2
call neomake#configure#automake('w')

" Interface Plugin Configurations {{{2
" Vim Airline: Lean & Mean Status/Tabline for Vim {{{2
let g:airline_theme='solarized'


" Fzf: A Command-Line Fuzzy Finder {{{2
" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Default fzf layout
" - down / up / left / right
let g:fzf_layout = { 'down': '~40%' }

" You can set up fzf window using a Vim command (Neovim or latest Vim 8 required)
let g:fzf_layout = { 'window': 'enew' }
let g:fzf_layout = { 'window': '-tabnew' }
let g:fzf_layout = { 'window': '10split enew' }

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'

" Replace the default dictionary completion with fzf-based fuzzy completion
inoremap <expr> <c-x><c-k> fzf#complete('cat /usr/share/dict/words')
" Commands Plugin Configurations {{{2


" Other Plugin Configurations {{{2
" Tabular: Align Text Based on Regular Expressions
if exists(":Tabularize")
  nmap <Leader>a= :Tabularize /=<CR>
  vmap <Leader>a= :Tabularize /=<CR>
  nmap <Leader>a: :Tabularize /:\zs<CR>
  vmap <Leader>a: :Tabularize /:\zs<CR>
endif


inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a
function! s:align()
  " Automatic tabularize when using '|'
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction

" Behaviors {{{1
" Override defaults {{{2
set nowrap " do not wrap lines
set foldmethod=marker " use markers to fold
set foldlevelstart=1 " fold everything beyond level 1
set hidden " allow opening new files without closing current one
set noswapfile " do not create swap files
set history=1000 " increase commandline history
set showcmd " show current command in the last line
set nojoinspaces " do not add space after sentences when joining lines
set complete-=t " do not use tag completion
set ignorecase " case sensitive search
set nohlsearch " disable hlsearch, inccommand and incsearch use their own highlight
set smartcase " only if pattern contains uppercase characters
set visualbell " use window flashing instead of beeping
if has('mouse')
  set mouse=nvi " enable mouse for normal and visual modes
endif
if has('nvim')
  set inccommand=nosplit " live substitution
endif
if has('mac')
  set clipboard=unnamed " allow direct copy and paste to system clipboard
endif

" Python for neovim {{{2
if has('win32')
  let g:python_host_prog = $HOME."/Applications/miniconda/envs/neovim2/python.exe"
  let g:python3_host_prog = $HOME."/Applications/miniconda/envs/neovim3/python.exe"
else
  let g:python_host_prog = $HOME."/Applications/miniconda/envs/neovim2/bin/python"
  let g:python3_host_prog = $HOME."/Applications/miniconda/envs/neovim3/bin/python"
endif

" Spell check {{{2
" Toggle spell checking on and off with `,s`
nmap <silent> <leader>s :set spell!<CR>

" Set region to USA English
set spelllang=en_us

" Open files from the same directory of the current file  {{{2
cnoremap <expr> %%  getcmdtype() == ':' ? fnameescape(expand('%:h')).'/' : '%%'
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" Prompt to open file with same name, different extension {{{2
map <leader>er :e <C-R>=expand("%:r")."."<CR>

" Fix the & command to preserve flag in normal+visual modes {{{2
nnoremap & :&&<Enter>
xnoremap & :&&<Enter>

" Strip trailing whitespace and global reformat {{{2
nmap _$ :call Preserve("%s/\\s\\+$//e")<CR>
nmap _= :call Preserve("normal gg=G")<CR>

function! Preserve(command)
  " Preparation: save last search, and cursor position.
  let l:_s=@/
  let l:l = line('.')
  let l:c = col('.')
  " Do the business:
  execute a:command
  " Clean up: restore previous search history, and cursor position
  let @/=l:_s
  call cursor(l:l, l:c)
endfunction

" Visual line repeat {{{2
xnoremap . :normal .<CR>
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

function! ExecuteMacroOverVisualRange()
  echo '@'.getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction
