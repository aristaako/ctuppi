#!/bin/bash
#===========================================================================
# Title       : ctuppi.sh
# Description : Script for setting up my dev environment
# Author      : aristaako
# Version     : 2.3
# Notes       : Check readme.md for commands cheatsheet
# Usage       : Just run the thing and hope for the best. See below
#               for further instructions
#===========================================================================
VERSION=2.3
CTUPPIID=ctuppi023000
LOCK=/tmp/$CTUPPIID.lock

DEFAULT_DISTRO=ubuntu
USER_DISTRO=
VIRTUALIZED=false

RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

declare -a OPERATION_STARTED=()
declare -a FAILED=()
declare -a OPERATION_LIST=()

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

apt_install() {
    display_name=$1
    [[ ! -z "$2" ]] && package_name=$2 || package_name=$display_name
    echo "Installing $display_name"
    operation="Installation: $package_name"
    OPERATION_STARTED+=( "$operation" )
    sudo apt install $package_name -y -q || FAILED+=( "$operation" )
}

apt_remove() {
    display_name=$1
    [[ ! -z "$2" ]] && package_name=$2 || package_name=$display_name
    echo "Removing $display_name"
    operation="Remove: $package_name"
    OPERATION_STARTED+=( "$operation" )
    if [ "$(which $package_name 2> /dev/null)" != "" ]; then    
        sudo apt remove $package_name -y -q || FAILED+=( "$operation" )
    else
        echo "$package_name not found"
    fi
    
}

install_konsole() {
    apt_install "konsole"
}

install_nerd_font() {
    echo "Installing FiraCode Nerd Font"
    OPERATION_STARTED+=( "Installation: FiraCode Nerd Font" )
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
    unzip FiraCode.zip -d FiraCode
    mkdir ~/.local/share/fonts/
    cp -r FiraCode/* ~/.local/share/fonts/
    rm FiraCode.zip
    rm -rf FiraCode
    fc-cache
}

copy_konsole_profile() {
    echo "Copying konsole profile"
    mkdir -p ~/.local/share/konsole
    cp files/konsole.profile ~/.local/share/konsole
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
    sed -i "s/_username_/$USER/" ~/.bash_aliases
}

install_git() {
    apt_install "git"
    apt_install "git-cola"
    apt_install "kdiff3"
}

configure_git() {
    git_username=$(git config user.name)
    git_useremail=$(git config user.email)
    if [[ -z "$git_username" ]]; then
        echo "Configuring git: git username not set"
        username=
        while [[ $username = "" ]]; do
            read -p "Enter git username: " username
        done
        git config --global user.name "$username"
    fi
    if [[ -z "$git_useremail" ]]; then
        echo "Configuring git: git email not set"
        email=
        while [[ $email = "" ]]; do
            read -p "Enter git email: " email
        done
        git config --global user.email "$email"
    fi
    echo "Configuring git: merge tool kdiff3"
    git config --global merge.tool kdiff3
}


install_utils() {
    apt_install "curl"

    echo "Installing ripgrep"
    OPERATION_STARTED+=( "Installation: ripgrep" )
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb
    sudo dpkg -i "ripgrep_12.1.1_amd64.deb"

    echo "Removing ripgrep deb"
    OPERATION_STARTED+=( "Remove: ripgrep_12.1.1_amd64.deb" )
    rm "ripgrep_12.1.1_amd64.deb"

    apt_install "python-pip"

    apt_install "python3"
    apt_install "python3-pip"

    apt_install "sqlite3" "libsqlite3-dev"

    apt_install "ruby"

    echo "Installing mailcatcher"
    OPERATION_STARTED+=( "Installation: mailcatcher" )
    sudo gem install mailcatcher 

    apt_install "gedit"

    wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add
    sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
    update_apt_packages
    apt_install "atom"

    apt_install "tree"

    echo "Installing SDKMAN!"
    OPERATION_STARTED+=( "Installation: SDKMAN!" )
    curl -s "https://get.sdkman.io" | bash
    source "/home/$USER/.sdkman/bin/sdkman-init.sh"

    apt_install "Silver Searcher" "silversearcher-ag"

    apt_install "ssh" "openssh-server"

    if [ "$VIRTUALIZED" == "false" ]; then
        apt_install "solaar for Logitech bluetooth devices" "solaar"
    fi
}

install_tmux() {
    apt_install "tmux"

    echo "Copying tmux configs to user root"
    cp files/tmux.conf ~/.tmux.conf
    cp files/splitter ~/.tmux/splitter
    cp files/tmux-status.sh ~/.tmux/tmux-status.sh

    echo "Downloading tpm"
    OPERATION_STARTED+=( "Installation: tpm" )
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    echo "Downloading tmux reset"
    OPERATION_STARTED+=( "Installation: tmux reset" )
    curl -Lo ~/.tmux/reset --create-dirs \
        https://raw.githubusercontent.com/hallazzang/tmux-reset/master/tmux-reset
}

install_nvm() {
    echo "Installing nvm"
    OPERATION_STARTED+=( "Installation: nvm" )
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    refresh_bashrc
}

install_node() {
    echo "Installing node"
    OPERATION_STARTED+=( "Installation: node" )
    nvm install node
}

install_java() {
    apt_install "default java jdk" "default-jdk"
}

install_docker() {
    echo "Preparing to install docker"
    echo "First cleaning older versions"
    apt_remove "docker"
    apt_remove "docker-engine"
    apt_remove "docker.io"
    apt_remove "containerd"
    apt_remove "runc"

    echo "Installing packages to allow apt to use repositories over HTTPS"
    apt_install "  apt-transport-https" "apt-transport-https"
    apt_install "  ca-certificates" "ca-certificates"
    apt_install "  gnupg-agent" "gnupg-agent"
    apt_install "  software-properties-common" "software-properties-common"

    if [ "$DEFAULT_DISTRO" == "$USER_DISTRO" ]; then
        echo "Adding Docker's official GPG key"
        curl -fsSL "https://download.docker.com/linux/$DEFAULT_DISTRO/gpg" | sudo apt-key add -

        echo "Setting up docker stable repository"
        sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/$DEFAULT_DISTRO \
        $(lsb_release -cs) \
        stable" -y

        update_apt_packages

        echo "Installing docker"
        apt_install "  docker-ce" "docker-ce"
        apt_install "  docker-ce-cli" "docker-ce-cli"
        apt_install "  containerd.io" "containerd.io"
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
    OPERATION_STARTED+=( "Installation: docker-compose" )
    pip3 install --user docker-compose
}

install_maven() {
    apt_install "maven"
}

install_gradle() {
    echo "Installing gradle"
    OPERATION_STARTED+=( "Installation: gradle" )
    sdk install gradle 6.6.1
}

install_aws() {
    apt_install "AWS" "awscli"
}

install_clojure() {
    apt_install "readline wrapper" "rlwrap"

    curl -O https://download.clojure.org/install/linux-install-1.10.1.727.sh
    chmod +x linux-install-1.10.1.727.sh
    sudo ./linux-install-1.10.1.727.sh

    echo "Removing clojure installation script"
    rm linux-install-1.10.1.727.sh

    echo "Install leiningen"
    OPERATION_STARTED+=( "Installation: Leiningen" )
    curl -o ~/bin/lein --create-dirs https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
    chmod a+x ~/bin/lein
    PATH=$PATH:~/bin
    lein
}

install_emacs() {
    apt_install "Emacs" "emacs"

    echo "Installing emacs live"
    OPERATION_STARTED+=( "Installation: Emacs live" )
    yes '' |bash <(curl -fksSL https://raw.github.com/overtone/emacs-live/master/installer/install-emacs-live.sh)

    echo "Installing flowapack"
    OPERATION_STARTED+=( "Installation: flowa-pack for Emacs" )
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
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    update_apt_packages
    apt_install "Visual Studio Code" "code"
}

install_brave() {
    curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
    echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    update_apt_packages
    apt_install "Brave browser" "brave-browser"
}

install_mpv() {
    if [ "$DEFAULT_DISTRO" == "$USER_DISTRO" ]; then
        echo "Adding repository for mpv"
        sudo add-apt-repository ppa:mc3man/mpv-tests -y
    fi
    apt_install "mpv"
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

create_operation_list() {
    longest_operation_name_length=0
    for item in "${OPERATION_STARTED[@]}"
    do
        item_length=${#item}
        if [ "$item_length" -gt "$longest_operation_name_length" ]; then
            longest_operation_name_length=$item_length
        fi
    done

    for value in "${OPERATION_STARTED[@]}"
    do
        value_length=${#value}
        value_shorter_than_longest=$((longest_operation_name_length-value_length))
        spaces=
        for i in $(seq 1 $value_shorter_than_longest); do spaces+=" "; done

        operation_row=
        if [[ ! " ${FAILED[*]} " =~ " ${value} " ]]; then
            INSTALLED+=( "$value" )
            operation_row="$spaces$value $GREEN OK $NO_COLOR"
            OPERATION_LIST+=( "$operation_row" )
        else
            operation_row="$spaces$value $RED NOK $NO_COLOR"
            OPERATION_LIST+=( "$operation_row" )
        fi
    done
}

print_operation_list() {
    echo ""
    for item in "${OPERATION_LIST[@]}"
    do
        echo -e "$item"
    done
    echo ""
}

setup_environment() {
    echo "Setting up dev environment"
    inquire_virtualbox
    inquire_distro
    update_apt_packages
    install_konsole
    install_nerd_font
    copy_konsole_profile
    copy_bash_configs
    set_username_to_bash_configs
    install_git
    configure_git
    install_utils
    install_tmux
    install_nvm
    refresh_bashrc
    install_node
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
    create_operation_list
    print_operation_list
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