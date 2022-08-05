" ~/.vimrc (macOS)
"
"   Compatibility of functionality with my terminal
"   app and keymap settings.
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
Plugin 'nathangrigg/vim-beancount'   " beancount file syntax

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
if has("clipboard")
    set clipboard=unnamed " copy to the system clipboard
    if has("unnamedplus") " X11 support
        set clipboard+=unnamedplus
    endif
endif

if has('mouse_sgr')
    set ttymouse=sgr
endif

imap <C-c> "+y<CR>
vmap <C-c> "+y<CR>
