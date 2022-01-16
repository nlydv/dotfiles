# shellcheck shell=bash
#
# ~/.bashrc (macOS)
#
#   Startup bash file for interactive non-login shells.
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


# ————SSH-Agent startup connection————————

export APPLE_SSH_ADD_BEHAVIOR="macos"

live_agent () {
    if [[ -S "$SSH_AUTH_SOCK" ]]; then
        # check if previous agent still alive by asking for keys
        _status=$(ssh-add -l &> /dev/null; echo $?)

        if [[ $_status -eq 0 ]]; then
            return 0                # is alive; still gaurding keys
        elif [[ $_status -eq 1 ]]; then
            ssh-agent -k            # murder agent for not doing its job, probs not its fault but ya never know
            return 1                # is dead now ¯\_(ツ)_/¯
        elif [[ $_status -eq 2 ]]; then
            return 1                # is dead
        fi
    else
        return 1    # sock not found, assume previous agent is dead
    fi
}

if ! live_agent &> /dev/null; then
    ssh_env="$HOME/.ssh/agent.env"
    [[ -e $ssh_env ]] || touch $ssh_env
    eval "$(cat $ssh_env)" &> /dev/null      # check if existing agent.env tells us where to find live agent, and
    if ! live_agent; then                    # look for live agent once more before getting new one, otherwise...
        ssh-agent -s > $ssh_env              #   get new agent & store info for future reference
        eval "$(cat $ssh_env)" &> /dev/null  #   then deploy the new agent
        ssh-add -A &> /dev/null              #   and tell it to gaurd our keys
    fi
    unset _status
fi

# Note: make sure macOS' default openssh tools (/usr/bin/ssh-*) used first in $PATH to use Keychain passwords

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

# Include GO bin
[ -d ~/go/bin ] && export PATH="$HOME/go/bin:$PATH"

# Homebrew Environment (also see `brew shellenv`)
if [ -x "$(which brew)" ]; then
    export HOMEBREW_PREFIX=$(brew --prefix)
    export HOMEBREW_CELLAR=$(brew --cellar)
    export HOMEBREW_REPOSITORY=$(brew --repository)
else
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
fi

export BREW=$HOMEBREW_PREFIX
export PATH="$BREW/bin:$BREW/sbin${PATH+:$PATH}"
export MANPATH="$BREW/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="$BREW/share/info:${INFOPATH:-}"

# Homebrew global bundle dump file location
export HOMEBREW_BUNDLE_FILE="$HOME/.brewfile"

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
#export PATH="/usr/local/opt/php@7.4/bin:$PATH"
#export PATH="/usr/local/opt/php@7.4/sbin:$PATH"
[ -e ~/.phpbrew/bashrc ] && . $HOME/.phpbrew/bashrc

# Python ... also see ~/.bash_aliases
#export PATH="/usr/local/opt/python/bin:$PATH"

# NVM: node/npm version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                    # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[ -s "$NVM_DIR/auto_nvm_use.sh" ] && \. "$NVM_DIR/auto_nvm_use.sh"  # This manually added .sh auto-detects and used node version if .nvmrc is found in PWD

# Dedupe any repeated directories in PATH
PATH="$(echo "$PATH" | sed -E -e 's/:([^:]*)(:.*):\1/:\1\2/' -e 's/^([^:]*)(:.*):\1/:\1\2/' -e 's/^:(\/.*)/\1/')"
export PATH

# ———————————————————————————————————————————————————————————————————————


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


# ————Other————————

# Add color to the command line!
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# iTerm2 Shell Integration
# source ~/.iterm2/iterm2_shell_integration.bash

# —————————————————
