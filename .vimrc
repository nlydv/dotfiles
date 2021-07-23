" ~/.vimrc (Linux server)
"
"   Compatibility of functionality with my terminal
"   app and keymap settings (unmodified clone of the macOS version for now).
"
"     Neel Yadav
"     06.29.2021

if has("syntax")
  syntax on
endif

set notermguicolors t_Co=16

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
