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
[ -r ~/.ssh/host_aliases ] && . $HOME/.ssh/host_aliases

# Shorthand aliases
alias sizes='sudo du -h -s ./* | sort -h'
alias tth='terminal-to-html'
alias alpine='alpine -sort date/reverse'
alias up='cd ..'

# Aliases 2 small 2 function
alias reload-shell='_path=$PATH;clear;[[ -r ~/.bash_profile ]] && . ~/.bash_profile || echo "err";PATH=$_path;unset _path'
alias fresh-brew='brew update; brew upgrade; brew upgrade --cask; brew cleanup --prune 0' # don't walk away, some upgrades ask for pass
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

# Python version aliases
#alias pip &> /dev/null && unalias pip
#alias pip2 &> /dev/null && unalias pip2
#alias python &> /dev/null && unalias python
#alias python2 &> /dev/null && unalias python2

#alias python2='/usr/bin/python2'            # Legacy python installed with macOS
#alias python3='/opt/homebrew/bin/python3'   # Latest python install via Homebrew
#alias python='/opt/homebrew/bin/python3'    # Default to user-installed python3
#alias pip3='/opt/homebrew/bin/pip3'         # Latest pip, comes with Homebrew pkg
#alias pip='/opt/homebrew/bin/pip3'          # Use our default python's pip

# Homebrew used to have a python@2 versioned package but I guess they finally got
# rid of it so no pip2 here since macOS doesn't seem to have a pip pre-installed
# alongside its legacy system version of python2

# Clipboard content shortcut
alias paste='echo "$(pbpaste)"'

