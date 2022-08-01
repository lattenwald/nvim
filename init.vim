if empty(glob(stdpath('config') . '/site/autoload/plug.vim'))
  silent exe '!curl -fLo ' . stdpath('config') . '/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')

Plug 'junegunn/vim-plug'

Plug 'tpope/vim-sensible'

Plug 'vim-scripts/wombat256.vim'

Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'itchyny/lightline.vim'

Plug 'airblade/vim-gitgutter'
Plug 'itchyny/vim-gitbranch'
Plug 'tpope/vim-fugitive'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'junegunn/vim-easy-align'

Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'antoinemadec/coc-fzf'

Plug 'plasticboy/vim-markdown'

Plug 'mattn/webapi-vim'
Plug 'mattn/vim-gist'

Plug 'pangloss/vim-javascript'

Plug 'preservim/nerdcommenter'

Plug 'vim-erlang/erlang-motions.vim'
Plug 'vim-erlang/vim-erlang-runtime'

Plug 'sbdchd/neoformat'

Plug 'elixir-editors/vim-elixir'
Plug 'cespare/vim-toml'
Plug 'ekalinin/Dockerfile.vim'

Plug 'terminalnode/sway-vim-syntax'

Plug 's3rvac/vim-syntax-redminewiki'

Plug 'liuchengxu/vista.vim'

Plug 'vimwiki/vimwiki'

Plug 'dkarter/bullets.vim'

Plug 'michal-h21/vimwiki-sync'

Plug 'ron-rs/ron.vim'

Plug 'sersorrel/vim-lilypond'

Plug 'AndrewRadev/bufferize.vim'

Plug 'purescript-contrib/purescript-vim'

Plug 'npatsakula/kql-nvim'

call plug#end()

let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-yaml', 'coc-rls', 'coc-elixir', 'coc-pyright', 'coc-perl']

colorscheme wombat256mod

let mapleader="\<Space>"

set tabstop=4
set shiftwidth=4
set novisualbell
set expandtab

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

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
imap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
imap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
imap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

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

" Other buffers/tabs stuff
nmap <C-S-PageDown> :tabmove +1<Return>
nmap <C-S-PageUp> :tabmove -1<Return>

" fzf
" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
nmap <leader>b :Buffers<Return>

" let g:fzf_action = {
"   \ "\\\\": 'tab drop' }

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

cnoremap <S-Insert>  <C-R>+

let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_folding = 'list'
nnoremap <leader><Space> <Plug>VimwikiToggleListItem

function! DoPrettyXML()
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  exe "set ft=" . l:origft
endfunction
command! PrettyXML call DoPrettyXML()

nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>
" set autochdir
autocmd BufEnter * silent! lcd %:p:h

" neovim-qt
" set guiTabline=0

" neovide
set guifont=Hack:h11

" Erlang autoformat
let g:neoformat_erlang_steamroller = {
  \ 'exe': 'rebar3',
  \ 'args': ['steamroll -f'],
  \ 'stdin': 0,
  \ 'replace': 1,
  \ }
let g:neoformat_enabled_erlang = ['steamroller']

" map <silent><Leader>g :call setbufvar(winbufnr(popup_atcursor(systemlist("cd " . shellescape(fnamemodify(resolve(expand('%:p')), ":h")) . " && git log --no-merges -n 1 -L " . shellescape(line("v") . "," . line(".") . ":" . resolve(expand("%:p")))), { "padding": [1,1,1,1], "pos": "botleft", "wrap": 0 })), "&filetype", "git")<CR>
