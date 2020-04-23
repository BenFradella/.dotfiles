if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

let g:python_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/bin/python3'

call plug#begin()

Plug 'morhetz/gruvbox'
Plug 'arcticicestudio/nord-vim'
Plug 'altercation/vim-colors-solarized'
Plug 'sheerun/vim-polyglot'
Plug 'ciaranm/detectindent'
Plug 'w0rp/ale'
Plug 'tpope/vim-surround'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'neovim/neovim'
Plug 'neovim/python-client'
Plug 'davidhalter/jedi'
Plug 'zchee/deoplete-jedi'

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

call plug#end()

" Remember which part of the file was being edited
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" DetectIndent
autocmd BufReadPost * :DetectIndent

" Press * to highlight all occurances of a word
set hlsearch
nnoremap * :keepjumps normal! mi*`i<CR>
nnoremap <esc><esc> :noh<return><esc>

" colors
syntax on
set background=dark
set termguicolors
colorscheme nord

" show relative line numbers, with actual line number for current line
set number
set relativenumber

set mouse=a

" LangServer
let g:LanguageClient_serverCommands = {
    \ 'sh':     ['bash-language-server', 'start'],
    \ 'python': ['pyls'],
    \ 'go':     ['~/go/bin/go-langserver']
    \ }

" ALE
let g:ale_linters = {
    \ 'sh': ['language_server'],
    \ }

" Deoplete
let g:deoplete#enable_at_startup = 1
call deoplete#custom#option('num_processes', str2nr(system("nproc")))
if !exists('g:deoplete#omni#input_patterns')
  let g:deoplete#omni#input_patterns = {}
endif

inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
