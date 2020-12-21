#!/bin/bash
#===========================================================================
# Title       : ctuppi.sh
# Description : Script for setting up my dev environment
# Author      : aristaako
# Version     : 2.0
# Notes       : Check readme.md for commands cheatsheet
# Usage       : Just run the thing and hope for the best. See below
#               for further instructions
#===========================================================================
VERSION=2.0
CTUPPIID=ctuppi020000
LOCK=/tmp/$CTUPPIID.lock

DEFAULT_DISTRO=ubuntu
USER_DISTRO=
VIRTUALIZED=false

showHelp() {
cat <<-END

Usage: ./ctuppi.sh 
        (to run Ctuppi) 
or ./ctuppi.sh [options]
        (to run Ctuppi options)

where options include:

-h | --help       print help message to output stream
-v | --version    print Ctuppi version information

END
}

showVersion() {
    echo "Ctuppi $VERSION"
}

inquire_virtualbox() {
    while true; do
        read -p "Is this a virtualized environment? (y/n) " yn
        case $yn in
            [Yy]* ) echo "Roger that."; VIRTUALIZED=true; break;;
            [Nn]* ) echo "Okay."; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

is_distro_debian() {
    while true; do
        read -p "Are you using debian based distro? (y/n) " yn
        case $yn in
            [Yy]* ) echo "Great."; USER_DISTRO=debian; break;;
            [Nn]* ) echo "Sadness. Ctuppi does not support your distro."; exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

inquire_distro() {
    while true; do
        read -p "Are you using ubuntu based distro? (y/n) " yn
        case $yn in
            [Yy]* ) echo "Okay."; USER_DISTRO=ubuntu; break;;
            [Nn]* ) is_distro_debian; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

update_apt_packages() {
   sudo apt update -y -q
}

install_konsole() {
    echo "Installing konsole"
    sudo apt install konsole -y -q
}

copy_bash_configs() {
    echo "Copying bash configs to user root"
    cp files/bash_aliases ~/.bash_aliases
    cp files/bashrc ~/.bashrc
    mkdir -p ~/opt/git-prompt
    cp files/git-prompt.sh ~/opt/git-prompt/git-prompt.sh
}

set_username_to_bash_configs() {
    echo "Setting current user [$USER] for the bash config paths"
    sed -i "s/_username_/$USER/"  ̃/.bash_aliases 
}

install_git() {
    echo "Installing git"
    sudo apt install git  -y -q

    echo "Installing git-cola"
    sudo apt install git-cola  -y -q
}

install_utils() {
    echo "Installing curl"
    sudo apt install curl -y -q

    echo "Installing ripgrep"
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb
    sudo dpkg -i "ripgrep_12.1.1_amd64.deb"

    echo "Removing ripgrep deb"
    rm "ripgrep_12.1.1_amd64.deb"

    echo "Installing pip"
    sudo apt install python-pip  -y -q

    echo "Installing python3 and pip3"
    sudo apt install -y python3 python3-pip -y -q

    echo "Installing sqlite3"
    sudo apt install libsqlite3-dev -y -q

    echo "Installing ruby"
    sudo apt install ruby-full -y -q

    echo "Installing mailcatcher"
    sudo gem install mailcatcher 

    echo "Installing gedit"
    sudo apt install gedit -y -q

    echo "Installing atom"
    sudo apt install atom -y -q

    echo "Installing tree"
    sudo apt install tree -y -q

    echo "Installing SDKMAN!"
    curl -s "https://get.sdkman.io" | bash
    source "/home/$USER/.sdkman/bin/sdkman-init.sh"

    echo "Installing Silver Searcher"
    sudo apt install silversearcher-ag

    echo "Installing ssh"
    sudo apt install openssh-server -y -q

    if [ "$VIRTUALIZED" == "false" ]; then
        echo "Installing solaar for Logitech bluetooth devices"
        sudo apt install solaar -y -q
    fi
}

install_tmux() {
    echo "Installing tmux"
    sudo apt install tmux  -y -q

    echo "Copying tmux configs to user root"
    cp files/tmux.conf ~/.tmux.conf
    cp files/splitter  ̃/.tmux/splitter

    echo "Downloading tpm"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    echo "Downloading tmux reset"
    curl -Lo ~/.tmux/reset --create-dirs \
        https://raw.githubusercontent.com/hallazzang/tmux-reset/master/tmux-reset
}

install_npm() {
    echo "Installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash

    echo "Installing node"
    nvm install node
}

install_java() {
    echo "Installing default java jdk"
    sudo apt install default-jdk -y -q
}

install_docker() {
    echo "Preparing to install docker"
    echo "First cleaning older versions"
    sudo apt remove docker docker-engine docker.io containerd runc -y -q

    echo "Installing packages to allow apt to use repositories over HTTPS"
    sudo apt install apt-transport-https ca-certificates gnupg-agent software-properties-common -y -q

    if [ "$DEFAULT_DISTRO" == "$USER_DISTRO" ]; then
        echo "Adding Docker's official GPG key"
        curl -fsSL "https://download.docker.com/linux/$DEFAULT_DISTRO/gpg" | sudo apt-key add -

        echo "Setting up docker stable repository"
        sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/$DEFAULT_DISTRO \
        $(lsb_release -cs) \
        stable"

        update_apt_packages

        echo "Installing docker"
        sudo apt install docker-ce docker-ce-cli containerd.io -y -q
    else
        echo "Downloading docker "
        sudo curl -L "https://download.docker.com/linux/$USER_DISTRO/dists/$(lsb_release -cs)/pool/stable/amd64/docker-ce_19.03.9~3-0~$USER_DISTRO-$(lsb_release -cs)_amd64.deb" -o "~/Downloads/docker-ce_19.03.9~3-0~$USER_DISTRO-$(lsb_release -cs)_amd64.deb"

        echo "Downloading docker cli"
        sudo curl -L "https://download.docker.com/linux/$USER_DISTRO/dists/$(lsb_release -cs)/pool/stable/amd64/docker-ce-cli_19.03.9~3-0~$USER_DISTRO-$(lsb_release -cs)_amd64.deb" -o "~/Downloads/docker-ce-cli_19.03.9~3-0~$USER_DISTRO-$(lsb_release -cs)_amd64.deb"

        echo "Downloading containerd.io"
        sudo curl -L "https://download.docker.com/linux/$USER_DISTRO/dists/$(lsb_release -cs)/pool/stable/amd64/containerd.io_1.3.7-1_amd64.deb" -o "~/Downloads/containerd.io_1.3.7-1_amd64.deb"

        echo "Installing containerd.io"
        sudo dpkg -i "~/Downloads/containerd.io_1.3.7-1_amd64.deb"

        echo "Installing docker-ce-cli"
        sudo dpkg -i "~/Downloads/docker-ce-cli_19.03.9~3-0~$USER_DISTRO-$(lsb_release -cs)_amd64.deb"

        echo "Installing docker-ce"
        sudo dpkg -i "~/Downloads/docker-ce_19.03.9~3-0~$USER_DISTRO-$(lsb_release -cs)_amd64.deb"

        echo "Removing downloaded docker debs"
        rm "~/Downloads/containerd.io_1.3.7-1_amd64.deb"
        rm "~/Downloads/docker-ce-cli_19.03.9~3-0~$USER_DISTRO-$(lsb_release -cs)_amd64.deb"
        rm "~/Downloads/docker-ce_19.03.9~3-0~$USER_DISTRO-$(lsb_release -cs)_amd64.deb"
    fi  

    sudo usermod -aG docker "$USER"  

    echo "Installing docker-compose with pip3"
    pip3 install --user docker-compose
}

install_maven() {
    echo "Installing maven"
    sudo apt install maven -y -q
}

install_gradle() {
    echo "Installing gradle"
    sdk install gradle 6.6.1
}

install_aws() {
    echo "Installing aws"
    sudo apt install awscli -y -q
}

install_clojure() {
    echo "Installing readline wrapper"
    sudo apt install rlwrap -y -q

    curl -O https://download.clojure.org/install/linux-install-1.10.1.727.sh
    chmod +x linux-install-1.10.1.727.sh
    sudo ./linux-install-1.10.1.727.sh

    echo "Removing clojure installation script"
    rm linux-install-1.10.1.727.sh

    echo "Install leiningen"
    curl -o ~/bin/lein --create-dirs https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
    chmod a+x ~/bin/lein
    PATH=$PATH:~/bin
    lein
}

install_emacs() {
    echo "Installing emacs"
    sudo apt install emacs -y -q

    echo "Installing emacs live"
    bash <(curl -fksSL https://raw.github.com/overtone/emacs-live/master/installer/install-emacs-live.sh)

    echo "Installing flowapack"
    git clone https://github.com/flowa/flowa-pack.git ~/.flowa-pack
    mv ~/.flowa-pack/.emacs-live.el ~/.emacs-live.el 
    cd ~/.flowa-pack
    git submodule init
    git submodule update
    cd ~/.flowa-pack/lib/helm
    make
    cd ~/

    echo "Setting emacs as the default editor"
    echo 'export EDITOR=~/bin/emacsnw' >> ~/.bashrc
}

install_vscode() {
    echo "Installing Visual Studio Code"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt install apt-transport-https
    sudo apt update
    sudo apt install code
}

install_brave() {
    echo "Installing Brave browser"
    sudo apt install apt-transport-https curl
    curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
    echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install brave-browser
}

install_mpv() {
    if [ "$DEFAULT_DISTRO" == "$USER_DISTRO" ]; then
        echo "Adding repository for mpv"
        sudo add-apt-repository ppa:mc3man/mpv-tests
    fi
    echo "Installing mpv"
    sudo apt install mpv
}

refresh_bashrc() {
    echo "Refreshing .bashrc"
    source ~/.bashrc
}

display_greetings() {
    echo "Thank you for using Ctuppi!"
    echo "Install tmux plugins by opening tmux and pressing PREFIX + I (capital i)."
    echo "Over and out."
}

setup_environment() {
    echo "Setting up dev environment"
    inquire_virtualbox
    inquire_distro
    update_apt_packages
    install_konsole
    copy_bash_configs
    set_username_to_bash_configs
    install_git
    install_utils
    install_tmux
    install_npm
    install_java
    install_docker
    install_maven
    install_gradle
    install_aws
    install_clojure
    install_emacs
    install_vscode
    install_brave
    install_mpv
    refresh_bashrc
    display_greetings
}

invalid() {
    echo "Invalid argument $1"
    echo "Use argument -h or --help for instructions."
}

while getopts ":hv-:" opt; do
    case $opt in
        h) 
            showHelp 
            exit 0 ;;
        v) 
            showVersion
            exit 0 ;;
        -) 
            case "$OPTARG" in
                version) 
                    showVersion
                    exit 0 ;;
                help) 
                    showHelp
                    exit 0 ;;
                *)
                    invalid "--${OPTARG}"
                    exit 0 ;;
            esac ;;
        *) 
            invalid "-$OPTARG"
            exit 0 ;;        
    esac
done

cleanup() {
    rm -f $LOCK
}

startup() {
    if [ -f "$LOCK" ]; then
        echo "Ctuppi already running"
        exit
    fi

    touch $LOCK

    trap cleanup EXIT
}

startup
setup_environment
