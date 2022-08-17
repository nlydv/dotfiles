# shellcheck shell=bash disable=SC2155,SC1090,SC1091
#
#   ~/.bashrc (Linux server)
#
#   Startup bash file for interactive non-login shells.
#   Apparently some OS' will run ~/.bash_profile for all login
#   shells. This is sourced by ~/.bash_profile anyways but is
#   otherwise run automatically by the system on interactive
#   shell invocation. So most stuff goes (or is sourced) here.
#
#   Neel Yadav
#   07.06.2021



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

# ————— Unchanged Defaults from /etc/skel ————————————————————————————
# ————————————————————————————————————————————————————————————————————

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'



# ————— SSH-Agent Startup Connection —————————————————————————————————
# ————————————————————————————————————————————————————————————————————

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
        ssh-add &> /dev/null                 #   and tell it to gaurd our keys
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
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Bash Completion
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

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

# PM2: node process manager
if [[ -n $(which pm2) ]]; then
    pm2sh="$HOME/.pm2/completion.sh"
    if [[ -s $pm2sh ]]; then
        . $pm2sh
    else
        pm2 completion > $pm2sh
        . $pm2sh
    fi
    unset pm2sh
fi

# Dedupe $PATH Directories
# shellcheck disable=SC2155,SC2046,SC2005,SC2086
export PATH=$(echo $(echo $PATH | awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print}') | sed -E 's/ +:$//g')



# ————— Clean $HOME == Happy $HOME ———————————————————————————————————
# ————————————————————————————————————————————————————————————————————

# Asserting default XDG spec for thoroughness
## for a practical TL;DR of XDG_BASEDIRs, check this brief blog
## post by ... *checks about page* ... Max from Hamburg, Germany:
## https://maex.me/2019/12/the-power-of-the-xdg-base-directory-specification/
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

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


# ————— Other/Misc ———————————————————————————————————————————————————
# ————————————————————————————————————————————————————————————————————


# Other Completions (manually save completion output from non-brew tools here)
for COMPLETION in /usr/local/etc/bash_completion.d/*; do
    [[ -r "$COMPLETION" ]] && source "$COMPLETION"
done

# PGP stuff
if [[ -d "$HOME/.gnupg" ]] && which gpg &> /dev/null; then
    export GPG_TTY=$(tty)
    gpgconf --create-socketdir
fi

# Somewhere over the rainbow
export GREP_COLOR='1;34'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
export LS_COLORS="di=1;34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43:*.tar=1;31:*.tgz=1;31:*.arj=1;31:*.taz=1;31:*.lzh=1;31:*.lzma=1;31:*.tlz=1;31:*.txz=1;31:*.zip=1;31:*.z=1;31:*.Z=1;31:*.dz=1;31:*.gz=1;31:*.lz=1;31:*.xz=1;31:*.bz2=1;31:*.bz=1;31:*.tbz=1;31:*.tbz2=1;31:*.tz=1;31:*.deb=1;31:*.rpm=1;31:*.jar=1;31:*.rar=1;31:*.ace=1;31:*.7z=1;31:*.rz=1;31:or=3;33:mi=90"
alias ls='ls --color=auto'
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# For timezone consistency
export TZ=America/Chicago

# Prefer C-style alphabetical sorting with 'ls' & things
export LC_COLLATE=C
export LANG=en_US.UTF-8 # reiterate default lang for everything else just in case

# Miscellaneous env variables
export LINES
export COLUMNS
export EDITOR=vim
