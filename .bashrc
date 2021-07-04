# shellcheck shell=bash
#
# ~/.bashrc (macOS)
#
#   Startup bash file for non-interactive login shells.
#   Apparently some OS' will run ~/.bash_profile for all login
#   shells. This is sourced by ~/.bash_profile anyways but is
#   otherwise run automatically by the system on interactive
#   shell invocation. So most stuff goes (or is sourced) here.
#
#     Neel Yadav
#     06.29.2021


# ————Basic startup checks & sourcing other dotfiles————————

# If not running interactively, don't do anything
if [ -z "$PS1" ]; then
   return
fi

# Make bash check its window size after a process completes
shopt -s checkwinsize

# Source personal aliases and functions
[ -r ~/.bash_aliases ] && . $HOME/.bash_aliases
[ -r ~/.bash_functions ] && . $HOME/.bash_functions

# Pull in my ANSI color/style escape code vars (used in command prompt)
[ -r ~/.bash_colors ] && . $HOME/.bash_colors

# Source dedicated file for custom command prompt
[ -r ~/.command_prompt ] && . $HOME/.command_prompt

# ——————————————————————————————————————————————————————————


# ————Bash completion sourcing————————

# Manually added commands to source bash-completion@2 and
# enable Homebrew formula's completion scripts to be read
export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
[ -r "/usr/local/etc/profile.d/bash_completion.sh" ] && . "/usr/local/etc/profile.d/bash_completion.sh"

# Manually sourcing bash-completion script for git because
# it wasn't working for whatever reason via Homebrew's setup
if [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]; then
  . "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
fi

# TODO: eventually look into if either of these 2 are still necessary

# ————————————————————————————————————


# ————SSH-Agent startup connection————————

running_agent () {
    if [[ -S "$SSH_AUTH_SOCK" ]]; then
        # testing if ssh-agent is running by asking it for keys
        ssh-add -l &> /dev/null
        [[ $? == 2 ]] && return 1 || return 0
    else
        # sock not found, assume is asleep
        return 1
    fi
}

ssh_env="$HOME/.ssh/agent.env"
if ! running_agent; then
    export SSH_AUTH_SOCK="$(cat $ssh_env 2> /dev/null)"     # check if agent.env can tell us where to find a woke agent
    if ! running_agent; then                                # ...and try connecting one more time before starting new agent
        eval $(ssh-agent -s) > $ssh_env                     # ...store new agent info for future reference
    fi
fi

ssh-add -A &> /dev/null # && ssh-add -A ~/.ssh/other-keys &> /dev/null

# Note: make sure macOS' default openssh tools (/usr/bin/ssh-*) used first in $PATH

# reference material:
#   https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
#   https://github.com/mattbostock/dotfiles/blob/master/ssh-agent-setup.sh
# ssh-add return codes:
#   0 = agent running, has keys
#   1 = agent running, no keys
#   2 = agent not running

# ————————————————————————————————————————


# ————Setting PATH locations & priortizing non-system executables————————

# Add user's home bin if it exists
[ -d ~/bin ] && export PATH="$HOME/bin:$PATH"

# OpenSSL Keg-Only Paths
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

# cURL Keg-Only Paths
export PATH="/usr/local/opt/curl/bin:$PATH"

# Ruby Gems Environment Variables
export GEM_HOME="/usr/local/lib/ruby/gems/3.0.0"
export PATH="$GEM_HOME/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"

# PHP/Composer Environment Variables
export COMPOSER_HOME="/Users/neel/.composer"
export PATH="$COMPOSER_HOME/vendor/bin:$PATH"
export PATH="/usr/local/opt/php@7.2/bin:$PATH"
export PATH="/usr/local/opt/php@7.2/sbin:$PATH"

# Python ... also see ~/.bash_aliases
export PATH="/usr/local/opt/python/bin:$PATH"

# NVM: node/npm version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ———————————————————————————————————————————————————————————————————————


# ————Other————————

# Add color to the command line!
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# iTerm2 Shell Integration
# source ~/.iterm2/iterm2_shell_integration.bash

# —————————————————
