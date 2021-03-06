if empty(glob(stdpath('config') . '/site/autoload/plug.vim'))
  silent exe '!curl -fLo ' . stdpath('config') . '/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')

Plug 'junegunn/vim-plug'

Plug 'tpope/vim-sensible'

Plug 'vim-scripts/wombat256.vim'

" Plug 'dense-analysis/ale'
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'itchyny/lightline.vim'
" Plug 'maximbaz/lightline-ale'
" Plug 'mengelbrecht/lightline-bufferline'

Plug 'airblade/vim-gitgutter'
Plug 'itchyny/vim-gitbranch'
Plug 'tpope/vim-fugitive'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-json'
" Plug 'hyhugh/coc-erlang_ls', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-yaml', {'do': 'yarn install --frozen-lockfile'}

Plug 'junegunn/vim-easy-align'

Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'plasticboy/vim-markdown'

Plug 'mattn/webapi-vim'
Plug 'mattn/vim-gist'

Plug 'pangloss/vim-javascript'

" Plug 'lambdalisue/vim-gista'

Plug 'preservim/nerdcommenter'

Plug 'jeetsukumaran/vim-buffergator'

Plug 'jremmen/vim-ripgrep'

Plug 'vim-erlang/erlang-motions.vim'
Plug 'vim-erlang/vim-erlang-runtime'

Plug 'elixir-editors/vim-elixir'
Plug 'cespare/vim-toml'
Plug 'ekalinin/Dockerfile.vim'

Plug 'terminalnode/sway-vim-syntax'

Plug 's3rvac/vim-syntax-redminewiki'

Plug 'liuchengxu/vista.vim'

Plug 'vimwiki/vimwiki'

Plug 'dkarter/bullets.vim'

Plug 'michal-h21/vimwiki-sync'

call plug#end()

colorscheme wombat256mod

let mapleader="\<Space>"

set tabstop=4
set shiftwidth=4
set novisualbell
set expandtab
set autochdir

set wildmenu
set wildmode=longest:full,full
set wildcharm=<C-Z>
cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
cnoremap <expr> <left> wildmenumode() ? "\<up>" : "\<left>"
cnoremap <expr> <right> wildmenumode() ? " \<bs>\<C-Z>" : "\<right>"

set clipboard=unnamedplus

" NERDTree
map <C-f> :NERDTreeToggle<CR>
map <C-F> :NERDTreeToggleVCS<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeIgnore=['#$', '^#']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Coc configuration
" https://github.com/neoclide/coc.nvim#example-vim-configuration
set hidden
set nobackup
set nowritebackup
set cmdheight=2
set updatetime=300
set shortmess+=c
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
"
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

"      \ 'tabline': {
"      \   'left': [ ['buffers'] ],
"      \   'right': [ ['close'] ]
"      \ },
"      \ 'component_expand': {
"      \   'buffers': 'lightline#bufferline#buffers'
"      \ },
"      \ 'component_type': {
"      \   'buffers': 'tabsel'
"      \ },
function! NearestScope() abort
  let info = get(b:, 'vista_cursor_info', {})
  return get(info, 'scope', '')
endfunction

set statusline+=%{NearestScope()}

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste', 'scope' ],
      \             [ 'cocstatus',  'currentfunction', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status',
      \   'currentfunction': 'CocCurrentFunction',
      \   'scope': 'NearestScope'
      \ },
      \ }

" Use auocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set number
map <C-N> :set number!<cr>
imap <C-N> <Esc>:set number!<cr>i

" show tabstopabs and trailing spaces
set listchars=tab:→\ ,trail:·
set list
map <C-P> :set list!<cr>
imap <C-P> <Esc>:set list!<cr>i

let g:gist_post_private = 1
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'

" remove trainling whitespaces
autocmd BufWritePre * :%s/\s\+$//e

" navigations between buffers
"" Alt+arrows
nmap <M-Left> <C-w><Left>
nmap <M-Right> <C-w><Right>
nmap <M-Up> <C-w><Up>
nmap <M-Down> <C-w><Down>

" BufferGator
let g:buffergator_viewport_split_policy = "R"
let g:buffergator_autoupdate = 1
let g:buffergator_autodismiss_on_select = 0
let g:buffergator_vsplit_size = 36
let g:buffergator_sort_regime = "basename"
let g:buffergator_show_full_directory_path = 0
nmap <leader>b :BuffergatorToggle<Return>

" TODOlist
" nnoremap :Rg FIXME\\\\\|TODO\\\\\|XXX<return>
nmap <leader>t :Rg FIXME\\\\|TODO\\\\|XXX

" Matches
function! Matches(pat)
    let buffer=bufnr("") "current buffer number
    let b:lines=[]
    execute ":%g/" . a:pat . "/let b:lines+=[{'bufnr':" . 'buffer' . ", 'lnum':" . "line('.')" . ", 'text': escape(getline('.'),'\"')}]"
    call setloclist(0, [], ' ', {'items': b:lines})
    lopen
endfunction
command! -nargs=1 Mat call Matches(<f-args>)
nnoremap <F3> :exec 'Mat' expand("<cword>")<CR>

let g:vista_icon_indent = ["|_ ", "|- "]
let g:vista_fold_toggle_icons = ['v', '>']
let g:vista_default_executive = 'ctags'
let g:vista_executive_for = {
    \ 'erl': 'coc',
    \ 'js': 'coc',
    \ 'ex': 'coc',
    \ 'vimwiki': 'markdown',
    \ 'md': 'markdown',
    \ 'markdown': 'toc',
    \ }
let g:vista_fzf_opt = ['--reverse']

autocmd FileType erlang let b:surround_98 = "<<\"\r\">>"

nnoremap <leader>v :Vista ctags<Return>
nnoremap <leader>V :Vista coc<Return>
nnoremap <leader>i :Vista finder fzf:ctags<Return>
nnoremap <leader>I :Vista finder fzf:coc<Return>

let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]

" neovim-qt
" set guiTabline=0

" map <silent><Leader>g :call setbufvar(winbufnr(popup_atcursor(systemlist("cd " . shellescape(fnamemodify(resolve(expand('%:p')), ":h")) . " && git log --no-merges -n 1 -L " . shellescape(line("v") . "," . line(".") . ":" . resolve(expand("%:p")))), { "padding": [1,1,1,1], "pos": "botleft", "wrap": 0 })), "&filetype", "git")<CR>
