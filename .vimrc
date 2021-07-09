" ~/.vimrc (Linux server)
"
"   Compatibility of functionality with my terminal
"   app and keymap settings (unmodified clone of the macOS version for now).
"
"     Neel Yadav
"     06.29.2021

syntax on
set notermguicolors t_Co=16
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

nmap <C-c> "+y<CR>
imap <C-c> "+y<CR>
vmap <C-c> "+y<CR>

nmap <ESC>[200~ "*p
imap <ESC>[200~ "*p
vmap <ESC>[200~ "*p
