" File-specific indentation.
" - tabstop     = ts  = number of spaces that <Tab> in file uses
" - softtabstop = sts = number of spaces that <Tab> uses while editing
" - shiftwidth  = sw  = number of spaces to use for (auto)indent step
autocmd FileType javascript setl ts=2 sts=2 sw=2
autocmd FileType python     setl ts=4 sts=4 sw=4 fdm=indent

" Insert timestamp.
nmap <F5> i<C-R>=substitute(system('date -u +"%FT%TZ // "'),'[\r\n]*$','','')<CR><Esc><CR>
imap <F5> <C-R>=substitute(system('date -u +"%FT%TZ // "'),'[\r\n]*$','','')<CR>

" Line numbering and highlighting.
set number
set relativenumber
set cursorline
highlight cursorline ctermbg=0 cterm=NONE

" Ruler.
set ruler  " Show line/column number.
set colorcolumn=80
highlight colorcolumn ctermbg=0

" Tabulation.
set tabstop=4  " Number of visual spaces per TAB.
set expandtab  " Tabs are spaces.
set autoindent
set smartindent

" Folding.
set foldmethod=marker
nnoremap <space>  za    " Space opens/closes folds.
nnoremap z<space> zczA  " Recursively open folds.

" Searching.
set incsearch  " Search as characters are entered.
set ignorecase
set smartcase
set hlsearch

" Colors. (https://jonasjacek.github.io/colors)
syntax on
highlight networkIdentifier ctermfg=9
" syntax match networkIdentifier '\v([0-9A-Za-z][0-9A-Za-z-]*[0-9A-Za-z]\.)+[0-9A-Za-z]+'  " Domain name.
syntax match networkIdentifier '\v([0-9]{1,3}\.){3}[0-9]{1,3}'                           " IP address.
syntax match networkIdentifier '\v([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})'               " MAC address.

" Lines.
set linebreak  " Don't line break in the middle of a word.

" Spell.
hi clear SpellBad
hi SpellBad cterm=underline

" Misc.
set backspace=indent,eol,start
