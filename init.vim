if empty(glob(stdpath('config') . '/site/autoload/plug.vim'))
  silent exe '!curl -fLo ' . stdpath('config') . '/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')

" vim-plug
Plug 'junegunn/vim-plug'

" Think of sensible.vim as one step above 'nocompatible' mode: a universal set of defaults that (hopefully) everyone can agree on.
Plug 'tpope/vim-sensible'

" color theme
Plug 'vim-scripts/wombat256.vim'

" parens/braces/…
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'

" status line
Plug 'itchyny/lightline.vim'

" git stuff
Plug 'airblade/vim-gitgutter'
Plug 'itchyny/vim-gitbranch'
Plug 'tpope/vim-fugitive'

" the coc
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" TODO check bindings
Plug 'junegunn/vim-easy-align'

" nerdtree
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" fzf and coc integration
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'antoinemadec/coc-fzf'

" tags view
Plug 'liuchengxu/vista.vim'

" github gist
Plug 'mattn/webapi-vim'
Plug 'mattn/vim-gist'

" TODO check bindings
Plug 'preservim/nerdcommenter'

" formatter
Plug 'sbdchd/neoformat'

" misc syntaxes not supported by polyglot
Plug 'ekalinin/Dockerfile.vim'
Plug 's3rvac/vim-syntax-redminewiki'
Plug 'ron-rs/ron.vim'
Plug 'npatsakula/kql-nvim'

" The plugin exposes the :Bufferize command, which runs the given command and shows its output in a temporary buffer.
Plug 'AndrewRadev/bufferize.vim'

" vimwiki
Plug 'vimwiki/vimwiki'
Plug 'dkarter/bullets.vim'
Plug 'michal-h21/vimwiki-sync'

" polyglot
Plug 'sheerun/vim-polyglot'

" sudoedit
Plug 'lambdalisue/suda.vim'

" snippets
Plug 'honza/vim-snippets'

" telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
call plug#end()

colorscheme wombat256mod
highlight Underlined guisp=#80a0ff
let mapleader="\<Space>"

set tabstop=4
set shiftwidth=4
set novisualbell
set expandtab

" command-line completion
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

let NERDCreateDefaultMappings=0
nnoremap <Leader>c<space> <Plug>NERDCommenterToggle
vnoremap <Leader>c<space> <Plug>NERDCommenterToggle
nnoremap <Leader>cc <Plug>NERDCommenterComment
vnoremap <Leader>cc <Plug>NERDCommenterComment

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Coc configuration
" https://github.com/neoclide/coc.nvim#example-vim-configuration

" coc lsp engines and plugins
let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-yaml', 'coc-rust-analyzer', 'coc-elixir', 'coc-pyright', 'coc-perl', '@yaegassy/coc-ansible', 'coc-snippets']

" yaml.ansible filetype and coc filetype
au BufRead,BufNewFile *.yaml.ansible set filetype=yaml.ansible
let g:coc_filetype_map = {
  \ 'yaml.ansible': 'ansible',
  \ }

set hidden
set nobackup
set nowritebackup
set cmdheight=2
set updatetime=500
set shortmess+=c
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" inoremap <silent><expr> <tab> coc#pum#visible() ? coc#pum#confirm() : "\<tab>"
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()
inoremap <silent><expr> <c-cr> coc#pum#visible() ? coc#pum#confirm() : "\<c-cr>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Use <leader>d to show documentation in preview window.
nnoremap <Leader>d :call <SID>show_documentation()<CR>

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

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
"
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

function! NearestScope() abort
  let info = get(b:, 'vista_cursor_info', {})
  return get(info, 'scope', '')
endfunction

let g:lightline = {
            \ 'colorscheme': 'wombat',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste', 'scope' ],
            \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
            \ },
            \ 'component_function': {
            \   'cocstatus': 'coc#status',
            \   'filename': 'LightlineFilename',
            \   'scope': 'NearestScope',
            \ }
            \ }


" https://github.com/itchyny/lightline.vim/issues/293#issuecomment-373710096
function! LightlineFilename()
  let root = fnamemodify(get(b:, 'gitbranch_path'), ':h:h')
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    return path[len(root)+1:]
  endif
  return expand('%')
endfunction

" Use autocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> ca  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> ce  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> cc  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> co  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> cs  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> cj  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> ck  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> cp  :<C-u>CocListResume<CR>

" https://github.com/neoclide/coc.nvim/issues/1775
let g:coc_disable_transparent_cursor = 1

" https://github.com/nvim-treesitter/nvim-treesitter
lua <<TREESITTER
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "rust", "erlang", "elixir", "perl", "bash", "lua",
    "dockerfile", "gitignore", "vim", "json5", "html", },
  sync_install = false,
  auto_install = true,
  }
TREESITTER

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
nmap <leader>f :Files<Return>
nmap <leader>c :Commits<Return>
nmap <leader>s :Snippets<Return>

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
let g:fzf_buffers_jump = 1

autocmd FileType erlang let b:surround_98 = "<<\"\r\">>"

nnoremap <leader>v :Vista ctags<Return>
nnoremap <leader>V :Vista coc<Return>
nnoremap <leader>i :Vista finder fzf:ctags<Return>
nnoremap <leader>I :Vista finder fzf:coc<Return>

let g:vista_sidebar_position = "vertical topleft"

cnoremap <S-Insert>  <C-R>+

let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_folding = 'list'
let g:vimwiki_key_mappings = { 'table_mappings': 0, }
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

"FZF Buffer Delete

function! s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines)
  execute 'bwipeout!' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

command! BD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers(lines) },
  \ 'options': '--multi --bind ctrl-a:select-all+accept'
\ }))

function! RipgrepFzf(query, fullscreen)
    let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
