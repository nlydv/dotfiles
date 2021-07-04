#!/usr/bin/env bash
#
# ~/.bash_aliases (macOS)
#
#   Custom user defined aliases
#   Sourced by ~/.bashrc
#
#     Neel Yadav
#     06.29.2021


# Quick SSH locations specified on a per-host basis
[ -r ~/.ssh/host_aliases ] && . ~/.ssh/host_aliases

# Shorthand aliases
alias sizes='sudo du -h -d 1'
alias tth='terminal-to-html'
alias alpine='alpine -sort date/reverse'
alias adog='git log --all --decorate --oneline --graph'

# Git aliases
alias dotfiles='git --git-dir=$HOME/Git/dotfiles.git/ --work-tree=$HOME'

# Python version aliases
# alias python3='/usr/local/opt/python3/bin/python3'
# alias pip3='/usr/local/opt/python3/bin/pip3'
#
# alias python='python3'
# alias pip='pip3'

# alias python2='/usr/bin/python'
# alias pip2='/usr/local/bin/pip'

# Other aliases
alias nvm-upgrade-lts='upgrade-nodejs' # just so it is visible when running `alias`
