# shellcheck shell=bash
#
# ~/.bash_profile (macOS)
#
#   Bash startup file for interactive login shells.
#   So basically I gather that you ought to use this startup
#   script to hold extra commands that you'd want only login
#   shells specifically to run in addition to everything in
#   ~/.bashrc (by sourcing .bashrc from here also).
#
#     Neel Yadav
#     06.29.2021


# Most of this stuff is basically just potential examples or
# placeholders for legit usage and/or personal referrence in
# the future. No reason (currently) to use on personal macbook.

# This is cute but pointless
localtime="$(date +%-H%M)"
greetings="Welcome back"

if [[ ! $(logname) == $(id -u -n) ]]; then
    _user="\e[1;34m$(id -u -n) \e[0;3;2m($(logname))\e[0m"
else
    _user="\e[1;34m$(id -u -n)\e[0m"
fi

if [[ "$localtime" -lt 430 ]]; then
    greetings="🛌  Getting awfully late"
    message="You humans ought not sacrafice sleep"
elif [[ "$localtime" -le 800 ]]; then
    greetings="🐓  You're up early"
elif [[ "$localtime" -lt 1230 ]]; then
    greetings="🌞  Good morning"
elif [[ "$localtime" -lt 1700 ]]; then
    greetings="👁 👁  Good afternoon"
else
    greetings="🌜  Good evening"
fi

echo -e "\e[1m$greetings, $_user"
[[ -n $message ]] && echo -e "$message"

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

echo ""

# Source non-login startup commands as well
[ -r ~/.bashrc ] && . ~/.bashrc
