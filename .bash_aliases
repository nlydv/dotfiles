#!/usr/bin/env bash
#
# ~/.bash_aliases (Linux server)
#
#   Custom user defined aliases
#   Sourced by ~/.bashrc
#
#     Neel Yadav
#     07.06.2021


# Quick SSH locations specified on a per-host basis
[ -r ~/.ssh/host_aliases ] && . $HOME/.ssh/host_aliases

# Shorthand aliases
alias sizes='sudo du -h -d 1'
alias alpine='alpine -sort date/reverse'

# Aliases 2 small 2 function
alias reload-nginx='sudo nginx -t && sudo systemctl reload nginx'
alias reload-shell='clear;[[ -r ~/.bash_profile ]] && . ~/.bash_profile || echo "cannot source ~/.bash_profile"'
alias path-list='printf $PATH | awk -v RS=: "{print}"'

# El-iases
alias lss='ls -Alth'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias adog='git log --all --decorate --oneline --graph'
alias dot='git --git-dir=$HOME/git/dotfiles.git/ --work-tree=$HOME'
alias uncommit='git reset --soft HEAD~1'    # undo last commit; keep changes
alias delcommit='git reset --hard HEAD~1'   # undo last commit; discard changes

# Python version aliases
alias python='/usr/bin/python3'
alias python2='/usr/bin/python'
alias pip='/usr/bin/pip3'
alias pip2='/usr/bin/pip'
alias mpython='/usr/local/lib/mailinabox/env/bin/python3'
alias mpip='/usr/local/lib/mailinabox/env/bin/pip'
