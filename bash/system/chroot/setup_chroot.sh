#!/bin/bash

(
    cd /home ;

    perl -e 'print "1234\n1234\nBenjamin Toll\n\n\n\n\n"' | adduser btoll ;
    echo -e "\n[INFO] Added user btoll" ;

    yes | apt-get install git sudo ;

    pushd /home/btoll ;
    git clone https://github.com/btoll/dotfiles.git ;
    cp dotfiles/bash/.bash* .
    cp dotfiles/git/.git* .
    cp dotfiles/vim/.vim* .
    popd ;

    chown -R btoll:btoll /home/btoll

    if [ $? -eq 0 ]; then
        echo "[INFO] Setup completed."
    else
        echo "[ERROR] Something went wrong."
    fi
)

