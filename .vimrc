
" Turn on syntax highlighting
syntax on

" Press jj to exit insert mode
imap jj <Esc>

" Map the diffing colors to be more similar to windiff
hi diffadd   guibg=#ffff00   guifg=#000000   gui=none
hi diffchange   guibg=#ffffc0   guifg=#000000   gui=none
hi difftext   guibg=#ffff00   guifg=#000000   gui=none
hi diffdelete   guibg=#ff0000   guifg=#000000   gui=none

hi diffadd   ctermbg=Yellow   ctermfg=Black   cterm=none
hi diffchange   ctermbg=Blue   ctermfg=White   cterm=none
hi difftext   ctermbg=Yellow   ctermfg=Black   cterm=none
hi diffdelete   ctermbg=Red   ctermfg=Black   cterm=none


" Highlight search terms
set hlsearch

" Find references to current symbol using Gtags
" # nmap <C+]> <esc>:Gtags -r <CR>

" Find definition to current symbol using Gtags
" nmap <C+[> <esc>:Gtags <CR>

set expandtab
set shiftwidth=2
set tabstop=2
set nowrap

" Show line numbers
set nu

" Case insensitive searches
set ic

" Search incrementally as you type
set incsearch

" Jump between vertical windows quickly
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-H> <C-W>h<C-W>_
map <C-L> <C-W>l<C-W>_

" Highlight the current line
set cursorline

" svn blame
function SvnBlame()
  silent !svn blame % > ~/svnblame.txt
  sp ~/svnblame.txt
endfunction

" from R plugin installation: http://www.lepem.ufc.br/jaa/r-plugin.html#r-plugin-installation
set nocompatible
syntax enable
filetype plugin on
filetype indent on

let g:ScreenImpl='Tmux'

" qnamebuf
nmap ,f :call QNameFileInit("", "", 0)<cr>:~

" vimscreen
map ,s :ScreenSend<CR>

" Plugins:
"  - vim screen: http://www.vim.org/scripts/script.php?script_id=2711
"  - vim-r-plugin: http://www.vim.org/scripts/script.php?script_id=2628
"      http://www.lepem.ufc.br/jaa/r-plugin.html#r-plugin-key-bindings
"  - vimcom (for Rsh): http://www.lepem.ufc.br/jaa/vimcom.html
"  - qnamebuf: search for file by name
"      http://www.vim.org/scripts/script.php?script_id=3217

" more sane copy/paste in gvim
nmap <C-V> "+gP
imap <C-V> <ESC><C-V>i
vmap <C-C> "+y

