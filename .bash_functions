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
    local name=$1

    [[ $1 == "-a" && -n $2 ]] && name=$2
    while [[ $(type -t $name) == "alias" ]]; do
        name=$(alias $name | sed -E "s/.*'(.*)'/\1/")
    done

    if [[ $1 == "-*" ]]; then
        echo "realx error: only available option is -a";
        exit 11;
    elif [[ -n $name ]]; then
	    realpath $(type -p $name);
    elif [[ $1 == "-a" ]]; then
        realpath $(type -ap $name);
    else
        echo -e "${bold}usage: realx [-a] NAME${reset}\n"
        echo -e "desc: Gets the first executable found in the current \$PATH"
	echo -e "      that's named NAME and outputs its 'real' underlying"
	echo -e "      executable file path by expanding redirects and"
	echo -e "      following symlinks.\n";
        echo -e "  -a  Do for all matches of NAME in \$PATH\n"
    fi
}

# colortest: output 8 ANSI Colors in normal & bold
# —————————
colortest () {
    for i in {0..7}; do
        test_normal="\e[0;3${i}mTesting color $i normal${reset}"
        echo -e $test_normal;
    done

    for i in {0..7}; do
        test_bolded="\e[1;3${i}mTesting color $i bold${reset}"
        echo -e $test_bolded;
    done
}

# upgrade-nodejs: simple command to upgrade nodejs/npm and transfer npm packages to new version via nvm
# ———————————
upgrade-nodejs () {
    echo "Getting available versions..."

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
