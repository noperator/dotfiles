" Notes/resources:
" - Mappings (https://stackoverflow.com/q/3776117)
"   - (re)?map:    recursive map (i.e., remap is on by default)
"   - noremap:     non-recursive map
"   - X(nore)?map: specify mode X
" - Colors
"   - https://jonasjacek.github.io/colors
"   - https://github.com/altercation/vim-colors-solarized
" - Indentation
"   - tabstop     = ts  = number of spaces that <Tab> in file uses
"   - softtabstop = sts = number of spaces that <Tab> uses while editing
"   - shiftwidth  = sw  = number of spaces to use for (auto)indent step

" File-specific indentation.
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

" Colors.
syntax on
autocmd BufRead */Hacktivity* highlight domain ctermfg=3
\ | syntax match domain '\v([0-9A-Za-z]([0-9A-Za-z-]*[0-9A-Za-z])?\.)+[0-9A-Za-z]+'
\ | highlight ip ctermfg=6
\ | syntax match ip '\v([0-9]{1,3}\.){3}[0-9]{1,3}'
\ | highlight timestamp ctermfg=2
\ | syntax match timestamp '\v[0-9]{4}(-[0-9]{2}){2}T([0-9]{2}:){2}[0-9]{2}Z'
\ | highlight comments ctermfg=10
\ | syntax match comments '\v(^|[^:])//.*|\{\{\{|\}\}\}'
\ | highlight header cterm=underline ctermfg=4
\ | syntax match header '\v^# \[.*\] #'
" \ | syntax match networkIdentifier '\v([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})'

" Lines.
set linebreak  " Don't line break in the middle of a word.

" Spell.
hi clear SpellBad
hi SpellBad cterm=underline

" Backspace wasn't working; this fixed it.
set backspace=indent,eol,start

" Alias commonly mistaken commands.
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))

" Underline current line with hyphens.
nmap U yyp<c-v>$r-

" Tab navigation like qutebrowser.
nmap K :tabprevious<CR>
nmap J :tabnext<CR>
