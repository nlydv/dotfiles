#!/usr/bin/env bash
#
# ~/.bash_functions
#
#   Custom user functions loaded on startup
#   Sourced by ~/.bashrc
#
#     Neel Yadav
#     06.29.2019


# submod: git submodule pull/push function
# ——————
submod () {
    exist=$(git submodule 2> /tmp/submod.err)
    git=$(cat /tmp/submod.err)
    if [[ -n $exist ]]; then
        if [[ $1 == "update" || $1 == "pull" ]]; then
            git submodule update --recursive --remote --merge
        elif [[ $1 == "push" ]]; then
            git add -A && git commit -m "Update submodules $(date '+%B %-d, %Y')" && git push
        fi
    elif [[ $git == "fatal: not a git repository (or any of the parent directories): .git" ]]; then
        printf "  Directory not part of git repository\r\n"
    else
        printf "  No submodules in current git directory\r\n"
    fi
}

# realx: get real underlying executable path
# —————
realx () {
    [[ -n $2 ]] && local name=$2 || local name=$1

    if [[ $1 =~ ^-.*$ ]] && [[ ! $1 =~ ^-[a|A]$ ]]; then
        echo "realx: invalid option"
        return 1
    elif ! type -t $name &> /dev/null; then
        echo "realx: unresolvable argument"
        return 1
    fi

    while [[ $(type -t $name) == "alias" ]]; do
        name=$(alias $name | sed -E "s/.*'(.*)'/\1/")
    done

    if [[ -n $1 && -n $name ]]; then
        realpath $(type -p $name) 2> /dev/null
        if [[ $1 =~ ^-[a|A]$ ]]; then
            realpath $(type -ap $2) 2> /dev/null
        fi
    else
        echo -e "${bold}usage: realx [-a] NAME${reset}"
        echo -e "desc:  Gets the first executable found in the current \$PATH"
        echo -e "       that's named NAME and outputs its 'real' underlying"
        echo -e "       executable path by expanding redirects and following"
        echo -e "       any symlinks.\n";
        echo -e "   -a  Do for all matches of NAME in \$PATH\n"
    fi
}

# colortest: output 8 ANSI Colors in normal & bold
# —————————
colortest () {
    for i in {0..7}; do
        color_output="Testing color $i\n\e[0;3${i}mnormal${reset} | \e[1;3${i}mbold${reset}\n\e[0;9${i}mlight ${reset} | \e[1;9${i}mlight bold${reset}\n"
        echo -e $color_output;
    done
}

# nvm-upgrade-lts: simple command to upgrade node/npm and transfer npm packages to new version via nvm
# ———————————————
nvm-upgrade-lts () {
    if [[ -z $(type -t nvm) ]]; then
        echo "error: nvm is not installed";
        return 1;
    else
        echo -e "Getting available versions...";
        echo -e "Using:   $(nvm current)\n";
    fi

    current=$(nvm version default &> /dev/null && echo $(nvm version default) || echo $(nvm version current));
    echo -e "${bold}Current${reset}: ${blue}${bold}$current${reset}";
    
    latest=$(nvm version-remote --lts);
    
    if [[ $latest == "N/A" ]]; then
        echo -e "\n${red}${bold}Error${reset} - unable to pull remote LTS versions\n";
        return 2;
    else
        echo -n -e "${bold}Latest${reset}:  ";
    fi
    
    if [[ $current == $latest ]]; then
        echo -e "${blue}${bold}$latest${reset}\n";
        echo -e "    Node.js is already up-to-date with the latest LTS release\n";
        return 0;
    else
        echo -e "${magenta}${bold}$latest${reset}\n";
        echo -e "    Updated LTS version is available.";
        read -e -r -t 60 -p "    Continue with upgrade? (y/N) - " input;
    
        case "$input" in 
            [yY][eE][sS] | [yY])
                echo -e "\nOk. Upgrading to ${magenta}${bold}$latest${reset} ...\n"
            ;;
            *)
                echo -e "\nAborted upgrade.\n";
                return 3
            ;;
        esac
    fi

    nvm use $current > /dev/null;
    nvm install --lts --default --reinstall-packages-from=current > /dev/null || return 4;
    nvm install-latest-npm > /dev/null;
 
    echo -e "\n${bold}Node.js successfully upgraded ${reset} ${blue}${bold}$current${reset} → ${magenta}${bold}$latest${reset}\n"
}


# extract: no more randomly guessing option combos
# ———————  credit: Mpho Mphego (https://dev.to/mmphego/share-your-bashrc-251n)
extract () {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1    ;;
             *.tar.gz)    tar xzf $1    ;;
             *.tar.xz)    tar xJf $1    ;;
             *.bz2)       bunzip2 $1    ;;
             *.rar)       rar x $1      ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xf $1     ;;
             *.tbz2)      tar xjf $1    ;;
             *.tgz)       tar xzf $1    ;;
             *.zip)       unzip $1      ;;
             *.Z)         uncompress $1 ;;
             *.7z)        7z x $1       ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# entropy: informational display of entropy avail in sys, updates every second
# ———————
entropy () {
    printf "\nAvailable entropy:\e[0;2m (press any key to exit)\e[0m\n"
    while true; do
        printf "$(cat /proc/sys/kernel/random/entropy_avail)"
        read -t 1 && printf "\n" && return 0
        printf "\r"
    done
}

# sizes: shortcut command for using `du` to get real sizes of files/directories. orig an alias
# —————
sizes () {
    if [[ $# -eq 0 ]]; then
        sudo du -h -s "$PWD"
    else
        sudo du -h -s "$@" | sort -h
    fi
}
