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

# MACOS SSH NOTES
#   1) Native keychain integration requires macOS' default
#      openssh tools (/usr/bin/ssh-*), so if extra openssh
#      installed, make builtins first in $PATH to use it
#   2) Running `ssh-add -A` (as below) does nothing if the
#      user Keychain doesnt contain any priv key passwords
#   3) Add to Keychain with `ssh-add -K <PATH-TO-KEY>` and
#      enter password once
#   4) Now it will remember that key-pass combo and future
#      `ssh-add -A` commands will add the key to ssh-agent
#   4) Likewise, the same command as in (3) but with extra
#      `-d` flag deletes pass from Keychain & ssh-agent
#   5) Apple's changing -A flag to --apple-load-keychain &
#      -K to --apple-use-keychain; both currently work the
#      same (with caveats), but see ssh-add(1) for details

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
    if ! live_agent &> /dev/null; then       # look for live agent once more before getting new one, otherwise...
        ssh-agent -s > $ssh_env              #   get new agent & store info for future reference
        eval "$(cat $ssh_env)" &> /dev/null  #   then deploy the new agent
        ssh-add -A &> /dev/null              #   and tell it to gaurd our keys
    fi
    unset _status
fi

# reference material:
#   https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
#   https://github.com/mattbostock/dotfiles/blob/master/ssh-agent-setup.sh
# ssh-add return codes:
#   0 = agent running, has keys
#   1 = agent running, no keys
#   2 = agent not running

# ————————————————————————————————————————


# ————Setting PATH locations & priortizing non-system executables————————

# Include GO bin
[[ -r $HOME/go/bin ]] && export PATH="$HOME/go/bin:$PATH"

# Homebrew Environment Variables (see `brew help shellenv`)
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# Homebrew config env options
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_INSTALL_UPGRADE=1

# Homebrew global bundle dump file location
export HOMEBREW_BUNDLE_FILE="$HOME/.brewfile"

# OpenSSL Keg-Only Paths
export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"

# cURL Keg-Only Paths
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# Ruby Gems Environment Variables
export GEM_HOME="/opt/homebrew/lib/ruby/gems/3.1.0"
export PATH="$GEM_HOME/bin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
# backward's compatibility for older gems in macOS Catalina and later (10.15+)
export SDKROOT=$(xcrun --show-sdk-path)

# PHP & PHPBrew & Composer Environment Variables
export COMPOSER_HOME="$HOME/.composer"
export PATH="$COMPOSER_HOME/vendor/bin:$PATH"
    #export PATH="/opt/homebrew/opt/php@7.4/bin:$PATH"
    #export PATH="/opt/homebrew/opt/php@7.4/sbin:$PATH"
[[ -e ~/.phpbrew/bashrc ]] && . $HOME/.phpbrew/bashrc

# Python Versioning and PATH Priority
if [[ -x /opt/homebrew/bin/python3 ]]; then
    if [[ ! -L /usr/local/bin/python ]]; then
        echo -e "Linking & prioritizing python3 over python2."
        echo -e "Admin password may be requested below.\n"

        sudo ln -s /opt/homebrew/bin/python3 /usr/local/bin/python &> /dev/null
        sudo ln -s /opt/homebrew/bin/python3-config /usr/local/bin/python-config &> /dev/null
        sudo ln -s /opt/homebrew/bin/pip3 /usr/local/bin/pip &> /dev/null
    fi
    export PATH="/usr/local/bin/python:/usr/local/bin/python-config:/usr/local/bin/pip:$PATH"
else
    echo -e "\n\e[1;33mWarning\e[0m: No python3 installation found in Homebrew bin."
    echo -e "Defaulting to deprecated python2 version pre-installed on system.\n"
    echo -e "To fix, run    \e[1;37mbrew install python3\e[0m    and then reload shell.\n"
fi

# Set env var for .pythonrc config file
export PYTHONSTARTUP="$HOME/.config/pythonrc"

# NVM - NodeJS & NPM Version Manager
export NVM_DIR="$HOME/.nvm"
## this loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
## this loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
## optional nvm script to detect and switch to config'd version when in dir with .nvmrc
[[ -s "$NVM_DIR/auto_nvm_use.sh" ]] && \. "$NVM_DIR/auto_nvm_use.sh"

## create env vars and dynamic symlink pointing to versions of node/npm
## executables set for use through nvm
update_nvm_links () {
    echo -e "Updating dynamic node/npm symlinks to nvm-installed executables."
    echo -e "Admin password may be requested below.\n"
    sudo ln -s $NVM_BIN/node /usr/local/bin/node
    sudo ln -s $NVM_BIN/npm /usr/local/bin/npm
}

for n in {node,npm}; do
    [[ ! -L /usr/local/bin/$n || $(realpath /usr/local/bin/$n) != $(realpath $NVM_BIN/$n) ]] \
        && update_nvm_links
done

# Add user's home bin if it exists
[[ -r $HOME/bin ]] && export PATH="$HOME/bin:$PATH"

# Dedupe $PATH Directories
export PATH="$(echo "$PATH" | sed -E -e 's/:([^:]*)(:.*):\1/:\1\2/' -e 's/^([^:]*)(:.*):\1/:\1\2/' -e 's/^:(\/.*)/\1/')"

# ———————————————————————————————————————————————————————————————————————


# ————Other————————

# Enable CLI completions via "bash-completion@2" Homebrew formula
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

# Other Completions (manually save completion output from non-brew tools here)
for c in /usr/local/etc/bash_completion.d/*; do
    [[ -r "$c" ]] && . "$c"
done

# GPG Pinentry Display (remote SSH, etc. pinentry redirect to orig local display)
export GPG_TTY=$(tty)

# Add color to the command line!
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# ————Shell Optimizations————————

# Reduce auto-generated dotfile clutter in $HOME + related opts
shopt -s cmdhist
shopt -s lithist

export HISTCONTROL="ignoredups"
export HISTDIR="$HOME/.history"
export HISTFILE="$HISTDIR/bash_history"

export SHELL_SESSION_DIR="$HISTDIR/bash_sessions"
export SHELL_SESSION_FILE="$SHELL_SESSION_DIR/$TERM_SESSION_ID.session"
[[ ! -e $SHELL_SESSION_DIR ]] && mkdir -p $SHELL_SESSION_DIR

export LESSHISTFILE="$HISTDIR/lesshist"
export NODE_REPL_HISTORY="$HISTDIR/node_repl_history"
export SQLITE_HISTORY="$HISTDIR/sqlite_history"

# Bash env vars needed for stuff
export COLUMNS
export LINES

# —————————————————

