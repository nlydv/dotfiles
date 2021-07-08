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
            git add -A && sudo git commit -a -m "Update submodules $(date '+%B %-d, %Y')" && git push
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
        echo "error: nvm is not installed"
        return 1
    else
        echo "Getting available versions..."
    fi

    node_cur=$(nvm current)
    latest_lts=$(nvm version-remote --lts)
    nodemod_cur="$HOME/.nvm/versions/node/${node_cur}/lib/node_modules/*"

    if [[ $latest_lts == "N/A" ]]; then
        echo "error: unable to get latest LTS version"
    elif [[ $node_cur == $latest_lts ]]; then
        echo "NodeJS is already up-to-date."
        return 0
    else
        echo -e "\nNew version available.\n\nCurrent: $node_cur\nLatest LTS: $latest_lts\n"
        read -e -r -t 60 -p "Continue with upgrade? (y\N) — " input
        case "$input" in
            [yY][eE][sS]|[yY])
                echo "Ok. Upgrading to $latest_lts ...";;
            *)
                return 1 ;;
        esac
    fi

    nvm install --lts --latest-npm
    node_new=$(nvm current)
    nodemod_new="$HOME/.nvm/versions/node/${node_new}/lib/node_modules"

    for i in $nodemod_cur; do
        if [[ -d $i && ! $(basename $i) == "npm" ]]; then
            cp -r $i $nodemod_new
        fi
    done
}

# extract: no more randomly guessing option combos
# ———————  credit: Mpho Mphego (https://dev.to/mmphego/share-your-bashrc-251n)
extract () {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1    ;;
             *.tar.gz)    tar xzf $1    ;;
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
