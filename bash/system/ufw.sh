#!/bin/bash
# Run as root!

# NOTE: Below is the old installation method before it was a shell script.
# while read -r line; do eval $line; done < $HOME/.ufwrc

if [ $EUID -ne 0 ]; then
    echo -e "$(tput setaf 1)[ERROR]$(tput sgr0) This script must be run as root!" 1>&2
    exit 1
fi

apt-get install ufw -y

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw deny 25/tcp

# Port 111 is rpcbind
# http://www.debian.org/doc/manuals/securing-debian-howto/ch12.en.html
# http://www.debian.org/doc/manuals/securing-debian-howto/ch-sec-services.en.html#s-rpc
ufw deny 111/tcp

ufw enable
ufw status

