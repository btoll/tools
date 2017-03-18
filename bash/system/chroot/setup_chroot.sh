#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo -e "$(tput setaf 1)[ERROR]$(tput sgr0) This script must be run as root!" 1>&2
    exit 1
fi

(
    apt-get update ;
    # Have schroot install these packages?
    apt-get install curl git sudo tmux vim -y ;

    ###############################################################################
    # Attempting to work around the "perl: warning: Setting locale failed" error...
#    apt-get install locales -y ;
#    localedef -i en_US -f UTF-8 en_US.UTF-8 ;
#    echo -e "\nLANGUAGE = en_US\nLC_ALL = en_US\nLANG = en_US\nLC_TYPE = en_US\n" > /etc/environment ;
    ###############################################################################

    echo -e "1234\n1234\nBenjamin Toll\n\n\n\n\n" | adduser btoll ;

    if [ $? -eq 0 ]; then
        echo -e "\n$(tput setaf 4)[INFO]$(tput sgr0) Added user btoll" ;
    elif [ ! -d /home/btoll ]; then
        # If the user already exists but the homedir doesn't, create it.
        # If the dir doesn't exist, it's because the user was auto-created
        # via schroot config or by some other means.
        echo -e "\n$(tput setaf 4)[INFO]$(tput sgr0) Creating home directory" ;
        mkdir /home/btoll
    fi

    pushd /home/btoll ;
    git clone https://github.com/btoll/dotfiles.git ;
    cp dotfiles/minimal/.* .
    echo -e "\n$(tput setaf 4)[INFO]$(tput sgr0) Installed dotfiles" ;
    popd ;

    chown -R btoll:btoll /home/btoll ;
    . /home/btoll/.bash_profile ;

    if [ $? -eq 0 ]; then
        echo "$(tput setaf 2)[SUCCESS]$(tput sgr0) Setup completed."
    else
        echo "$(tput setaf 1)[ERROR]$(tput sgr0) Something went terribly wrong."
    fi
)

