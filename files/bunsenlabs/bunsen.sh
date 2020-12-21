#!/bin/bash
#===========================================================================
# Title       : bunsen.sh
# Description : Script for copying bunsenlabs configs
# Author      : aristaako
# Version     : 1.0
# Usage       : Run the script. It will copy the files. Yes?
#===========================================================================
VERSION=1.0
BUNSENID=bunsen010000
LOCK=/tmp/$BUNSENID.lock

showHelp() {
cat <<-END

Usage: ./bunsen.sh 
        (to run Bunsen config copy script) 
or ./bunsen.sh [options]
        (to run Bunsen config copy script options)

where options include:

-h | --help       print help message to output stream
-v | --version    print Bunsen config copy script version information

END
}

showVersion() {
    echo "Bunsen config copy script $VERSION"
}

copy_bunsenlabs_configs() {
    echo "Copying bunsenlabs configs"
    cp conky.conf ~/.config/conky/conky.conf
    cp prepend.csv ~/.config/jgmenu/prepend.csv
}

setup_bunsenlabs() {
    echo "Setting up bunsenlabs"
    copy_bunsenlabs_configs
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
        echo "Bunsen config copying already running"
        exit
    fi

    touch $LOCK

    trap cleanup EXIT
}

startup
setup_bunsenlabs
