# shellcheck shell=bash
#
#   ~/.bash_profile (Linux server)
#
#   Bash startup file for interactive login shells.
#   So basically I gather that you ought to use this startup
#   script to hold extra commands that you'd want only login
#   shells specifically to run in addition to everything in
#   .bashrc (by sourcing ~/.bashrc from here also).
#
#   Neel Yadav
#   07.06.2021


# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# Remote logins via SSH display user's source IP address
if [[ -n $SSH_CLIENT ]]; then
    remote_login="$(echo $SSH_CLIENT | sed -n -E 's/^(.*) [0-9]+ [0-9]+/\1/p')"
    echo -e "Logging in remotely from ${remote_login}"
fi

# You have mail
if [[ -n $(cat /var/mail/$(logname) 2> /dev/null) ]]; then
    printf " ✉️   \e[3mYou've got mail\e[0m "
    if [[ $(grep --count "Subject:" /var/mail/$(logname)) -gt 1 ]]; then
        printf "[$(grep --count "Subject:" /var/mail/$(logname))]\n"
    else
        printf "\n"
    fi
fi
