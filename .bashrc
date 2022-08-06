# shellcheck shell=bash disable=SC2155,SC1090,SC1091
#
#   ~/.bashrc (macOS)
#
#   Startup bash file for interactive non-login shells.
#   Apparently some OS' will run ~/.bash_profile for all login
#   shells. This is sourced by ~/.bash_profile anyways but is
#   otherwise run automatically by the system on interactive
#   shell invocation. So most stuff goes (or is sourced) here.
#
#   Neel Yadav
#   06.29.2021



# ————— Basic Startup Checks, Sourcing Other Dotfiles ————————————————
# ————————————————————————————————————————————————————————————————————

# If not running interactively, don't do anything
if [[ -z "$PS1" ]]; then
   return
fi

# Make bash check its window size after a process completes
shopt -s checkwinsize

# Source personal bash aliases
[[ -r "$HOME/.bash/aliases" ]]   && source "$HOME/.bash/aliases"

# Source personal bash functions
[[ -r "$HOME/.bash/functions" ]] && source "$HOME/.bash/functions"

# Source my ANSI color/style escape code vars (used in .bash/prompt)
[[ -r "$HOME/.bash/colors" ]]    && source "$HOME/.bash/colors"

# Source dedicated file for custom command prompt
[[ -r "$HOME/.bash/prompt" ]]    && source "$HOME/.bash/prompt"

# Source private env vars and configs that aren't version controlled
[[ -r "$HOME/.bash/env" ]]       && source "$HOME/.bash/env"



# ————— SSH-Agent Startup Connection —————————————————————————————————
# ————————————————————————————————————————————————————————————————————

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

# shellcheck disable=SC2086
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



# ————— $PATH Locations, Prioritize Non-System Executables ———————————
# ————————————————————————————————————————————————————————————————————
# @TODO split up and organize this section into relevant parts

# Include GO bin
[[ -r $HOME/go/bin ]] && export PATH="$HOME/go/bin:$PATH"

# Homebrew environment variables (see `brew help shellenv`)
if [[ $(arch) == "arm64" ]]; then
    export BREW="/opt/homebrew"
else
    export BREW="/usr/local/homebrew"
fi

export BREW_CELLAR="$BREW/Cellar"
export BREW_REPO="$BREW"
export PATH="$BREW/bin:$BREW/sbin${PATH+:$PATH}"
export MANPATH="$BREW/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="$BREW/share/info:${INFOPATH:-}"

# Homebrew config env options
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_INSTALL_UPGRADE=1

# Homebrew global bundle dump file location
export HOMEBREW_BUNDLE_FILE="$HOME/Archive/Installed/Brewfile-$(date +%y%m%d)"

# Homebrew "Command Not Found" CLI utility ( see: https://t.ly/2mPt )
HB_CNF_HANDLER="$BREW_REPO/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
if [ -f "$HB_CNF_HANDLER" ]; then
    source "$HB_CNF_HANDLER";
fi

# OpenSSL Keg-Only Paths
export PATH="$BREW/opt/openssl@1.1/bin:$PATH"

# cURL Keg-Only Paths
export PATH="$BREW/opt/curl/bin:$PATH"

# Ruby Keg-Only Paths
export GEM_HOME="$BREW/lib/ruby/gems/3.1.0"
export PATH="$GEM_HOME/bin:$PATH"
export PATH="$BREW/opt/ruby/bin:$PATH"

# Backward's compatibility for older gems in macOS Catalina and later (10.15+)
export SDKROOT="$(xcrun --show-sdk-path)"

# Python environment variables and prioritize unversioned Python3 execs
export PATH="$BREW/opt/python@3.9/libexec/bin:$PATH"
export PYTHONSTARTUP="$HOME/.config/pythonrc"

# PHP & PHPBrew & Composer environment variables
export COMPOSER_HOME="$HOME/.composer"
export PATH="$COMPOSER_HOME/vendor/bin:$PATH"
    #export PATH="/opt/homebrew/opt/php@7.4/bin:$PATH"
    #export PATH="/opt/homebrew/opt/php@7.4/sbin:$PATH"
[[ -e "$HOME/.phpbrew/bashrc" ]] && . "$HOME/.phpbrew/bashrc"

# NVM - NodeJS & NPM Version Manager
export NVM_DIR="$HOME/.nvm"
## this loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
## this loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
## optional nvm script to detect and switch to config'd version when in dir with .nvmrc
[[ -s "$NVM_DIR/auto_nvm_use.sh" ]] && source "$NVM_DIR/auto_nvm_use.sh"

# Add user's home bin if it exists
[[ -r $HOME/bin ]] && export PATH="$HOME/bin:$PATH"

# Mint - Swift CLI tool installer and dependency manager
export PATH="$HOME/.mint/bin:$PATH"

# Spicetify - Tools to customize/modify Spotify desktop client
export PATH="$PATH:$HOME.spicetify"

# Dedupe $PATH Directories
# shellcheck disable=SC2155,SC2046,SC2005,SC2086
export PATH=$(echo $(echo $PATH | awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print}') | sed -E 's/ +:$//g')



# ————— Clean $HOME == Happy $HOME ———————————————————————————————————
# ————————————————————————————————————————————————————————————————————

# Reducing auto-generated $HOME clutter from Bash itself
shopt -s cmdhist
shopt -s lithist

export HISTCONTROL="ignoredups"
export HISTDIR="$HOME/.history"
export HISTFILE="$HISTDIR/bash_history"

export SHELL_SESSION_DIR="$HISTDIR/bash_sessions"
export SHELL_SESSION_FILE="$SHELL_SESSION_DIR/$TERM_SESSION_ID.session"
[[ ! -e "$SHELL_SESSION_DIR" ]] && mkdir -p "$SHELL_SESSION_DIR"

# Redirect external programs' $HOME clutter
export LESSHISTFILE="$HISTDIR/lesshist"
export NODE_REPL_HISTORY="$HISTDIR/node_repl_history"
export SQLITE_HISTORY="$HISTDIR/sqlite_history"

# Defined here instead of in .bash/aliases for logical grouping
alias wget='wget --hsts-file ~/.history/wget-hsts'
alias alpine='alpine -p "$HOME/.config/alpine/pinerc" -pwdcertdir "$HOME/.config/alpine/smime"'



# ————— Other/Misc ———————————————————————————————————————————————————
# ————————————————————————————————————————————————————————————————————

# Enable CLI completions via "bash-completion@2" Homebrew formula
#[[ -r "$BREW/etc/profile.d/bash_completion.sh" ]] && . "$BREW/etc/profile.d/bash_completion.sh"

if type brew &> /dev/null; then
    if [[ -r "$BREW/etc/profile.d/bash_completion.sh" ]]; then
        source "$BREW/etc/profile.d/bash_completion.sh"
    else
        for COMPLETION in "$BREW/etc/bash_completion.d/"*; do
            [[ -r "$COMPLETION" ]] && source "$COMPLETION"
        done
    fi
fi

# Other Completions (manually save completion output from non-brew tools here)
for COMPLETION in /usr/local/etc/bash_completion.d/*; do
    [[ -r "$COMPLETION" ]] && source "$COMPLETION"
done

# GPG Pinentry Display (remote SSH, etc. pinentry redirect to orig local display)
export GPG_TTY=$(tty)

# Add color to the command line!
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# For timezone consistency
export TZ=America/Chicago

# Miscellaneous env variables
export LINES
export COLUMNS
export EDITOR=vim
export NODE_NO_WARNINGS=1
