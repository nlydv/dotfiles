# shellcheck shell=bash
#
# ~/.bash_profile (Linux server)
#
#   Bash startup file for interactive login shells.
#   So basically I gather that you ought to use this startup
#   script to hold extra commands that you'd want only login
#   shells specifically to run in addition to everything in
#   ~/.bashrc (by sourcing .bashrc from here also).
#
#     Neel Yadav
#     07.06.2021


# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# Source non-login startup commands as well
[ -r ~/.bashrc ] && . ~/.bashrc

export TZ='America/Chicago'
