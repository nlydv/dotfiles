" ~/.vimrc (macOS)
"
"   Compatibility of functionality with my terminal
"   app and keymap settings.
"
"     Neel Yadav
"     06.29.2021

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
