" ~/.vimrc (Linux server)
"
"   Compatibility of functionality with my terminal
"   app and keymap setting. Mostly identical to macOS.
"
"   Neel Yadav
"   06.29.2021


" Vim startup and file remapping
set nocompatible
set viminfofile=~/.vim/viminfo

" Vundle plugin manager
filetype off                         " required
set rtp+=~/.vim/bundle/Vundle.vim    " set the runtime path to include Vundle
call vundle#begin()                  " and initialize

Plugin 'VundleVim/Vundle.vim'        " let Vundle manage Vundle, required
Plugin 'chriskempson/base16-vim'     " to use base16-tomorrow-night theme
"Plugin 'nathangrigg/vim-beancount'   " beancount file syntax

call vundle#end()                    " required
filetype plugin indent on            " required

" Tell Vim to use sane tab/spacing rules
set tabstop=4
set shiftwidth=4
set expandtab

" —————————————————————————————————————————————— "

syntax on
set notermguicolors t_Co=16

colorscheme base16-tomorrow-night
hi Normal ctermbg=NONE
hi Normal guibg=NONE

set mouse=a
if has('mouse_sgr')
    set ttymouse=sgr
endif

if has("clipboard")
    set clipboard=unnamed " copy to the system clipboard
    if has("unnamedplus") " X11 support
        set clipboard+=unnamedplus
    endif
endif

vmap <C-c> "+y<CR>

nmap <ESC>[200~ "+p<CR>
imap <ESC>[200~ "+p<CR>
vmap <ESC>[200~ "+p<CR>
