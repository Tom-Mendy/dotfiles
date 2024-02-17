" ============ VimPlug ============
" Automatic installation
if empty (glob('~/.vim/autoload/plug.vim')) 
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
          \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
autocmd VimEnter *
  \ if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) 
  \| PlugInstall --sync | q 
  \| endif

" set the <leader> to a key
let mapleader = " "

" *** plugins ***
call plug#begin('~/.vim/plugged')

Plug 'Nero-F/vim-tek-header'

set shiftwidth=4
call plug#end()
" =================================

set visualbell

" show the command
set showcmd

set colorcolumn=80

" relative line
set nu rnu
static number line
set number

" enable cursor
set mouse=a

" add other file extention
filetype on

" set title
set title

" map save
map <C-Q> :wq<CR>
" map escape
inoremap jk <Esc>
inoremap kj <Esc>
inoremap JK <Esc>
inoremap KJ <Esc>
vnoremap q <Esc>

" Remove the color for the pool day
syntax on

set shiftwidth=4
set tabstop=4
set expandtab
set smartindent
