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
Plug 'iCyMind/NeoSolarized'

Plug 'sheerun/vim-polyglot'
Plug 'rluba/jai.vim'

Plug 'ciaranm/detectindent'
Plug 'tpope/vim-surround'

Plug 'neovim/neovim'
Plug 'neovim/nvim-lspconfig'

call plug#end()


" Remember which part of the file was being edited
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif


" DetectIndent
" Setup some default values before calling DetectIndent
set expandtab
set tabstop=4
set shiftwidth=4
autocmd BufReadPost * :DetectIndent

" Fix extra indentation in sh case statements
let b:sh_indent_options = {
      \ 'case-labels': 0,
      \ }
" ... and jai case statements
let b:jai_indent_options = {
      \ 'case_labels':0
      \ }

" allow toggling between spaces and tabs
function TabToggle()
  if &expandtab
    set noexpandtab
    set tabstop=4
  else
    set expandtab
  endif
endfunction


set hlsearch
" Don't scroll the buffer on *
nnoremap <silent> *  :let @/ = '\<' . expand('<cword>') . '\>' <bar> set hls <bar> call histadd('/', @/) <cr>
" ... or on g*
nnoremap <silent> g* :let @/ =        expand('<cword>')        <bar> set hls <bar> call histadd('/', @/) <cr>
" clear highlighting on double ESC
nnoremap <silent> <esc><esc> :let @/ = "" <cr>


" ESC from terminal edit mode
tnoremap <Esc> <C-\><C-n>

" open help pages in vertical splits
cabbrev help vert help
cabbrev h vert h
" and open splits to the right
set splitright

" colors
syntax on
set background=dark
set termguicolors
" set spell
colorscheme NeoSolarized

" show relative line numbers, with actual line number for current line
set number
set relativenumber
" autoscroll the buffer to keep at least N lines visible on either side of the cursor
set scrolloff=16

set mouse=a

" Highlight the Nth column
set textwidth=100
set colorcolumn=+1
" Don't visually wrap long lines
set nowrap


" tab-completion
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\S'
        return "\<tab>"
    else
        return "\<C-x>\<C-o>"
    endif
endfunction

inoremap <expr><TAB> pumvisible() ? "\<C-n>" : InsertTabWrapper()
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" LSP
lua <<EOF
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<Cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d',       '<Cmd>lua vim.diagnostic.goto_prev()<CR>',  opts)
vim.api.nvim_set_keymap('n', ']d',       '<Cmd>lua vim.diagnostic.goto_next()<CR>',  opts)
vim.api.nvim_set_keymap('n', '<space>q', '<Cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Use LSP as the handler for formatexpr.
  vim.api.nvim_buf_set_option(bufnr, 'formatexpr', 'v:lua.vim.lsp.formatexpr')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD',        '<Cmd>lua vim.lsp.buf.declaration()<CR>',             bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd',        '<Cmd>lua vim.lsp.buf.definition()<CR>',              bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi',        '<Cmd>lua vim.lsp.buf.implementation()<CR>',          bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gt',        '<Cmd>lua vim.lsp.buf.type_definition()<CR>',         bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr',        '<Cmd>lua vim.lsp.buf.references()<CR>',              bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K',         '<Cmd>lua vim.lsp.buf.hover()<CR>',                   bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>',     '<Cmd>lua vim.lsp.buf.signature_help()<CR>',          bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',    bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>',      bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', bufopts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f',  '<Cmd>lua vim.lsp.buf.formatting()<CR>',  bufopts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'clangd', 'glslls', 'gopls', 'pylsp', 'bashls', 'zls', }
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    },
    settings = {
      pylsp = {
        plugins = {
          pylint = {
            enabled = true
          }
        }
      }
    }
  }
end
EOF
