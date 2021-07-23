#!/bin/bash
#
# ~/.install/setup.sh (Linux server)
#
#   Custom install script to auto-setup all the things!
#   Meant for fresh VM server instances only and is really only only designed
#   for my own purposes in mind. Other install scripts are sourced from here.
#
#     Neel Yadav
#     07.16.2021


# ————Basics———————————————————————————————————————————————————————————
echo -e "\n  ——BASICS——\n"
sudo add-apt-repository -y ppa:git-core/ppa
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt update
sudo apt -y upgrade
sudo apt -y install build-essential coreutils automake autoconf make libtool openssl libssl-dev tzdata util-linux adduser haveged \
curl wget git gnupg nmap vim unzip fail2ban ufw htop bash bash-completion bash-builtins bash-doc units sqlite3 jq python3 python3-pip python3-venv
sudo apt -y autoremove

[[ ! -e /usr/local/bin/python && -e /usr/bin/python3 ]] && sudo ln -s /usr/bin/python3 /usr/local/bin/python
[[ ! -e /usr/local/bin/pip && -e /usr/bin/pip3 ]] && sudo ln -s /usr/bin/pip3 /usr/local/bin/pip


# ————Security—————————————————————————————————————————————————————————
echo -e "\n  ——SECURITY——\n"
# The following rules are just a default configuration that can be changed later when
# setting up specific server types (Mail or DNS servers, for example).
echo "Adding firewall rules to ufw..."

sudo ufw limit 22                           # IP ratelimit SSH port
sudo ufw reject 25                          # reject (politely) outbound SMTP port
sudo ufw reject 53                          # reject (politely) DNS port traffic
sudo ufw allow http; sudo ufw allow https   # allow web traffic on ports 80,443
sudo ufw allow OpenSSH                      # allow OpenSSH profile (just in case, don't wanna get locked out)

echo "Enabling ufw with new rules..."
if sudo ufw status | grep -q "inactive"; then
    sudo ufw enable && sudo ufw status
else
    sudo ufw reload && sudo ufw status
fi


# ————Dotfiles—————————————————————————————————————————————————————————
echo -e "\n  ——DOTFILES——\n"
[[ ! -d $HOME/git ]] && mkdir $HOME/git
cd $HOME/git || exit 12

dot="git --git-dir=$HOME/git/dotfiles.git/ --work-tree=$HOME"

if [[ ! -d dotfiles.git ]]; then
    git clone -n --bare git@github.com:nlydv/dotfiles.git
    echo -e '.dotfiles\n.gnupg/**\n.ssh/**\n.bash_history\n.bash_sessions\n~/[gG]it/' >> $HOME/git/dotfiles.git/info/exclude
    $dot config --local status.showUntrackedFiles no
    $dot config --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    $dot config --local remote.origin.pushurl "git@github.com:nlydv/dotfiles.git"
    $dot fetch --all; $dot branch -u origin/linux linux; $dot branch -u origin/macos macos

    cd $HOME || exit 12
    if ! $dot checkout linux 2> /dev/null; then
        defdots=$($dot checkout linux 2>&1 | sed -n -E 's/^\s+(.*)$/\1/p')
        [[ ! -d $HOME/Archive ]] && mkdir -p $HOME/Archive/default-dots
        for i in $defdots; do
            mv $i $HOME/Archive/default-dots
        done
        if ! $dot checkout linux; then
            echo "error: unable to checkout dotfiles"
            exit 11
        fi
    fi
else
    echo 'git/dotfiles.git already exists... skipping dotfiles setup.'
fi
# @TODO: any situs where unwanted effects from this script overwritting itself while checking out dotfiles could cause problems?
unset dot

echo -e "\nPulling public PGP key from keyserver..."
gpg --keyserver hkps://keys.openpgp.org --receive-keys ED84CBAAA8A7B576
echo -e "\nSetting public PGP key as trusted..."
_keyfp=$(gpg --list-keys ED84CBAAA8A7B576 | head -n2 | tail -n1 | tr -d '[:blank:]')
echo -e "5\ny\n" | gpg --command-fd 0 --edit-key "$_keyfp" trust
gpg --update-trustdb


# ————Timezone—————————————————————————————————————————————————————————
echo -e "\n  ——TIMEZONE——\n"
echo "Localtime set to America/Chicago (US Central Time) by default"
echo "If necessary change the local timezone later using 'timedatectl'"
export TZ='America/Chicago'
sudo timedatectl set-timezone $TZ


# ————NVM — node/npm version manager———————————————————————————————————
echo -e "\n  ——NVM——\n"
echo -e "Downloading nvm from git to '$HOME/.nvm' ...\n"
curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash &> /dev/null

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [[ $(nvm current) == "none" ]]; then
    nvm install --lts --latest-npm
else
    echo "——Error: pre-existing node version installed with nvm. skipping."
fi


# ————Webserver — optionally install Nginx & PHP———————————————————————
echo -e "\n  ——WEBSERVER——\n"
read -e -r -t 60 -p "Would you like to setup a webserver on this machine? (y/N) — " response
if [[ $? -gt 128 ]]; then
    echo -e "——Response timeout: web server install skipped"
    exit 13
elif [[ $response =~ [yY][eE][sS]|[yY] ]]; then
    if [[ ! -e $HOME/.install/web.sh ]]; then
        echo '——web.sh not found in ~/.install'
    elif [[ ! -x $HOME/.install/web.sh ]]; then
        sudo chmod +x $HOME/.install/web.sh
    fi
    echo "Ok. Installing and configuring Nginx & PHP"
    sudo $HOME/.install/web.sh
else
    echo "Skipping web server install."
fi


# ————Unautomated reminder—————————————————————————————————————————————
echo -e "\n  ——DONE!——\n"
if [[ -z $(cat /proc/swaps | sed -n 2p) ]]; then
    echo -e "\e[1mDon't forget to setup swap space!\e[0m"
    echo -e "reference: https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-20-04\n"
fi
echo -e "\e[1mLogout then log back in to load new configs.\n\e[0m"
