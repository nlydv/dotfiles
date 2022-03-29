#!/usr/bin/env bash
#
# ~/.bash_aliases (macOS)
#
#   Custom user defined aliases
#   Sourced by ~/.bashrc
#
#     Neel Yadav
#     06.29.2021


# Quick SSH locations specified on a per-user basis (don't want public here)
[ -r ~/.ssh/host_aliases ] && . $HOME/.ssh/host_aliases

# Shorthand aliases
alias tth='terminal-to-html'
alias alpine='alpine -sort date/reverse'
alias up='cd ..'

# Aliases 2 small 2 function
alias reload-shell='_path=$PATH;clear;[[ -r ~/.bash_profile ]] && . ~/.bash_profile || echo "err";PATH=$_path;unset _path'
alias fresh-brew='brew update; brew upgrade; brew upgrade --cask; brew autoremove; brew cleanup --prune 0' # don't walk away, some upgrades ask for pass
alias path-list='printf $PATH | awk -v RS=: "{print}"'

# El-iases
alias lss='ls -Alth'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias adog='git log --all --decorate --oneline --graph'
alias dot='git --git-dir=$HOME/Git/dotfiles.git/ --work-tree=$HOME'
alias uncommit='git reset --soft HEAD~1'    # undo last commit; keep changes
alias delcommit='git reset --hard HEAD~1'   # undo last commit; discard changes

# Clipboard content shortcut
alias paste='echo "$(pbpaste)"'

