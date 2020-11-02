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
autocmd FileType tex        setl ts=2 sts=0 sw=2

" Insert timestamp.
nmap <F5> i<C-R>=substitute(system('date -u +"%FT%TZ // "'),'[\r\n]*$','','')<CR><Esc><CR>
imap <F5> <C-R>=substitute(system('date -u +"%FT%TZ // "'),'[\r\n]*$','','')<CR>

" Insert collapsible Markdown and place cursor at summary.
nmap cm o<details><summary></summary><CR><p><CR><CR>```<CR>```<CR><CR></p><CR></details><CR><Esc>8k18li

" Insert hN-level fold and place cursor at header.
nmap ch1 i#  {{{<CR><CR><CR><CR>}}}<Esc>4ki
nmap ch2 i##  {{{<CR><CR><CR><CR>}}}<Esc>4kli
nmap ch3 i###  {{{<CR><CR><CR><CR>}}}<Esc>4k2li

" Line numbering and highlighting.
set number
set relativenumber
set cursorline
highlight cursorline ctermbg=0 cterm=NONE

" Ruler.
set ruler  " Show line/column number.
highlight colorcolumn ctermbg=0
set colorcolumn=80,120
nmap T :set textwidth=79<CR>
" highlight ErrorOverLength ctermbg=red   
" match ErrorOverLength /\%121v.\+/

" Tabulation.
" - https://stackoverflow.com/a/1878983
set tabstop=4      " Max width of actual tab character.
set shiftwidth=4   " Size of indent.
set softtabstop=0
set expandtab      " Tab key inserts spaces instead of tab characters.
set smarttab
" set autoindent
" set smartindent

" Folding.
set foldmethod=marker
nnoremap <space>  za    " Space opens/closes folds.
nnoremap z<space> zczA  " Recursively open folds.

" Markdown folding.
set nocompatible
if has("autocmd")
  filetype plugin indent on
endif
let g:markdown_minlines = 1000

" Searching.
set incsearch  " Search as characters are entered.
set ignorecase
set smartcase
set hlsearch

" Colors.
syntax on
" highlight style      ctermfg=4  cterm=underline
" highlight redacted   ctermfg=1
" highlight attachment ctermfg=2
" highlight timestamp  ctermfg=2
" highlight domain     ctermfg=3
" highlight header     ctermfg=4  cterm=underline
" highlight ip         ctermfg=6
" highlight comments   ctermfg=10
" autocmd BufRead */{Hacktivity,quality_assurance}* syntax match domain '\v([0-9A-Za-z]([0-9A-Za-z-]*[0-9A-Za-z])?\.)+[0-9A-Za-z]+'
" \ | syntax match ip '\v([0-9]{1,3}\.){3}[0-9]{1,3}'
" \ | syntax match timestamp '\v[0-9]{4}(-[0-9]{2}){2}T([0-9]{2}:){2}[0-9]{2}Z'
" \ | syntax match comments '\v(^|[^:])//.*|\{\{\{|\}\}\}'
" \ | syntax match header '\v^# ?\[.*\] ?#'
" \ | syntax match style '\v^(bc|p)\.{1,2}'
" \ | syntax match attachment '\v^!.*!$'
" \ | syntax match redacted '\[REDACTED\]'
" \ | syntax match macaddress '\v([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})'

" Lines.
set linebreak  " Don't line break in the middle of a word.

" Spell.
hi clear SpellBad
hi SpellBad cterm=underline
nmap S :set spell!<CR>

" Backspace wasn't working; this fixed it.
set backspace=indent,eol,start

" Alias commonly mistaken commands.
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
cnoreabbrev <expr> W  ((getcmdtype() is# ':' && getcmdline() is# 'W' )?('w') :('W') )
cnoreabbrev <expr> w' ((getcmdtype() is# ':' && getcmdline() is# "w'")?('w') :("w'"))

" Underline current line with hyphens.
nmap U yyp<c-v>$r-

" Tab navigation like qutebrowser.
nmap K :tabprevious<CR>
nmap J :tabnext<CR>

" Insert single newline without entering insert mode.
nmap <S-Enter> O<Esc>j
nmap <CR> o<Esc>k

" Reload config file.
nmap R :source ~/.vimrc<CR>

" Open in external editor.
nmap <C-T> :silent !open -a Typora.app '%:p'<CR>
