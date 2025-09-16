" Share config with Vim.
" - https://vi.stackexchange.com/a/15548
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

" Load plugins.
call plug#begin(stdpath('data') . '/plugged')
Plug 'neovim/nvim-lspconfig'                                " LSP core
Plug 'glepnir/lspsaga.nvim'                                 " LSP UI features
" Plug 'hrsh7th/nvim-compe'                                   " Autocomplete
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Syntax highlight
" Plug 'nvim-treesitter/nvim-treesitter-refactor'             " Smart refactor
Plug 'psf/black', { 'branch': 'stable' }
" Plug 'folke/lsp-colors.nvim'
" Plug 'NLKNguyen/papercolor-theme'
Plug 'morhetz/gruvbox'
" Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
" Plug 'szymonmaszke/vimpyter'
Plug 'z0mbix/vim-shfmt', { 'for': 'sh' }
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" Plug 'sbdchd/neoformat'
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install --frozen-lockfile --production',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html'] }
Plug 'github/copilot.vim'
Plug 'preservim/vim-markdown'
Plug 'lewis6991/gitsigns.nvim'
" require 'lspconfig'

call plug#end()

" let fc = g:firenvim_config['localSettings']
" let fc['https?://[^/]*slack.com/*'] = { 'takeover': 'never', 'priority': 1 }

colorscheme gruvbox

" Load plugin configurations.
lua <<EOF
require("completion")
require("lsp")
require("treesitter")
require'lspconfig'.gopls.setup{}
require'lspconfig'.ts_ls.setup {}
require('gitsigns').setup{
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    vim.keymap.set('n', '<leader>td', gs.toggle_deleted, {buffer = bufnr})
    vim.keymap.set('n', '<leader>tw', gs.toggle_word_diff, {buffer = bufnr})
  end
}
EOF

" LSP mappings, borrowed from:
" - https://github.com/nikvdp/nvim-lsp-config/blob/45a950f19cc583539ec329460876bf965d7bc9db/init.vim#L93
" nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
" nnoremap <silent> <C-]> <cmd>lua vim.lsp.buf.definition()<CR>
" nnoremap <silent> gD    <cmd>lua vim.lsp.buf.declaration()<CR>
" nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
" nnoremap <silent> gi    <cmd>lua vim.lsp.buf.implementation()<CR>
" nnoremap <silent> K     <cmd>Lspsaga hover_doc<CR>
" nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
" nnoremap <silent> <C-p> <cmd>Lspsaga diagnostic_jump_prev<CR>
" nnoremap <silent> <C-n> <cmd>Lspsaga diagnostic_jump_next<CR>
" nnoremap <silent> gf    <cmd>lua vim.lsp.buf.formatting()<CR>
" nnoremap <silent> gn    <cmd>lua vim.lsp.buf.rename()<CR>
" nnoremap <silent> ga    <cmd>Lspsaga code_action<CR>
" xnoremap <silent> ga    <cmd>Lspsaga range_code_action<CR>
" nnoremap <silent> gs    <cmd>Lspsaga signature_help<CR>

" LSP.
nnoremap <silent>K :Lspsaga hover_doc<CR>
nnoremap <silent> gs :Lspsaga signature_help<CR>
nnoremap <silent>gr :Lspsaga rename<CR>

" Completion mappings.
" inoremap <silent><expr> <C-Space> compe#complete()
" inoremap <silent><expr> <CR>      compe#confirm('<CR>')
" inoremap <silent><expr> <C-e>     compe#close('<C-e>')
" inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
" inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

" Code formatting.
let g:shfmt_extra_args = '-i 4'  " Indent with 4 spaces.
let g:shfmt_fmt_on_save = 1  " Auto format *.sh on save.
autocmd BufWritePre *.py execute ':Black'

let g:python3_host_prog = '/opt/homebrew/bin/python3'

" let g:go_fmt_command = "gofmt"
let g:go_imports_autosave = 0

" let g:neoformat_try_node_exe = 1
" autocmd BufWritePre *.js Neoformat
" autocmd BufWritePre *.ts Neoformat
autocmd BufWritePre *.js Prettier
autocmd BufWritePre *.ts Prettier
