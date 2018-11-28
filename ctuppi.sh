#!/bin/bash
#===========================================================================
# Title       : ctuppi.sh
# Description : Script for setting up my dev environment
# Author      : aristaako
# Version     : 1.0
# Notes       : Check readme.md for commands cheatsheet
# Usage       : Just run the thing and hope for the best
#===========================================================================

update_apt_packages() {
   sudo apt-get update -y -q
}

install_konsole() {
    echo "Installing konsole"
    sudo apt-get install konsole -y -q
}

copy_bash_configs() {
    echo "Copying bash configs to user root"
    cp files/bash_aliases ~/.bash_aliases
    cp files/bashrc ~/.bashrc
    mkdir -p ~/opt/git-prompt
    cp files/git-prompt.sh ~/opt/git-prompt/git-prompt.sh
}

install_tmux() {
    echo "Installing tmux"
    sudo apt-get install tmux  -y -q

    echo "Copying tmux configs to user root"
    cp files/tmux.conf ~/.tmux.conf

    echo "Downloading tmux reset"
    curl -Lo ~/.tmux/reset --create-dirs \
        https://raw.githubusercontent.com/hallazzang/tmux-reset/master/tmux-reset
}

install_git() {
    echo "Installing git"
    sudo apt install git  -y -q

    echo "Installing git-cola"
    apt-get install git-cola  -y -q
}

install_utils() {
    echo "Installing ripgrep"
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep_0.10.0_amd64.deb
    sudo dpkg -i ripgrep_0.10.0_amd64.deb

    echo "Installing pip"
    sudo apt-get install python-pip  -y -q

    echo "Installing curl"
    sudo apt install curl -y -q

    echo "Installing brew"
    sudo apt install linuxbrew-wrapper -y -q
    #Warning: /home/linuxbrew/.linuxbrew/bin is not in your PATH.

    echo "Installing build-essential"
    sudo apt-get install build-essential -y -q

    echo "Install gcc"
    brew install gcc    
}

install_npm() {
    echo "Installing nvm"
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

    echo "Installing node"
    nvm install node
}

install_java() {
    #Or maybe install older jdk:
    #sudo apt-get install openjdk-8-jdk -y -q
    sudo apt-get install default-jdk -y -q
}

install_clojure() {
    echo "Installing readline wrapper"
    sudo apt-get install rlwrap -y -q

    echo "Installing clojure"
    curl -O https://download.clojure.org/install/linux-install-1.9.0.397.sh
    chmod +x linux-install-1.9.0.397.sh
    sudo ./linux-install-1.9.0.397.sh

    echo "Install leiningen"
    sudo apt-get install leiningen-clojure -y -q
}

install_emacs() {
    echo "Installing emacs"
    sudo apt-get install emacs -y -q

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

refresh_bashrc() {
    echo "Refreshing .bashrc"
    source ~/.bashrc
}

setup_environment() {
    echo "Setting up dev environment"
    update_apt_packages
    install_konsole
    copy_bash_configs
    install_git
    install_utils
    install_npm
    install_java
    install_clojure
    install_emacs
    refresh_bashrc
}

setup_environment
