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
alias alpine='alpine -sort date/reverse'
alias up='cd ..'

# Aliases 2 small 2 function
alias reload-nginx='sudo nginx -t && sudo systemctl reload nginx'
alias reload-shell='_path=$PATH;clear;[[ -r ~/.bash_profile ]] && . ~/.bash_profile || echo "err";PATH=$_path;unset _path'
alias path-list='printf $PATH | awk -v RS=: "{print}"'

# El-iases
alias lss='ls -Alth'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias adog='git log --all --decorate --oneline --graph'
alias dot='git --git-dir=$HOME/git/dotfiles.git/ --work-tree=$HOME'
alias recent='git recent'
alias commit='f() { git commit -m "$*" 1> /dev/null && recent; unset f; }; f'
alias uncommit='git reset --soft HEAD~1'    # undo last commit; keep changes
alias delcommit='git reset --hard HEAD~1'   # undo last commit; discard changes

# Python version aliases
[[ -d /usr/local/lib/mailinabox ]] && alias mpython='/usr/local/lib/mailinabox/env/bin/python3'
[[ -d /usr/local/lib/mailinabox ]] && alias mpip='/usr/local/lib/mailinabox/env/bin/pip'

# Misc.
alias gpg='gpg --no-autostart'
