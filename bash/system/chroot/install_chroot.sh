#!/bin/bash
# Run as root!

if [ $EUID -ne 0 ]; then
    echo -e "$(tput setaf 1)[ERROR]$(tput sgr0) This script must be run as root!" 1>&2
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "$(tput setaf 1)[ERROR]$(tput sgr0) Not enough arguments."
    echo "Usage: $0 <chroot_name>"
    exit 1
fi

CHROOT_NAME="$1"

echo "$(tput setaf 4)[INFO]$(tput sgr0) Installing the chroot will take several minutes."

# Dependencies.
yes | apt-get install debootstrap schroot

# Create the dir where the jail is installed.
mkdir -p /srv/chroot/$CHROOT_NAME

# Create a config entry for the jail.
echo -e "[$CHROOT_NAME]\
\ndescription=Debian 8.2.0\
\ntype=directory\
\ndirectory=/srv/chroot/$CHROOT_NAME\
\nusers=btoll\
\ngroups=sbuild\
\nroot-users=btoll\
\nroot-groups=root" > /etc/schroot/chroot.d/$CHROOT_NAME

# Finally, create the jail itself.
# debootstrap jessie /var/chroot/ http://ftp.debian.org/debian
debootstrap --no-check-gpg jessie /srv/chroot/$CHROOT_NAME file:///home/btoll/virt

if [ $? -eq 0 ]; then
    # See /etc/schroot/default/copyfiles for files to be copied into the new chroot.
    echo "$(tput setaf 2)[SUCCESS]$(tput sgr0) Chroot installed in /srv/chroot/$CHROOT_NAME"
else
    echo "$(tput setaf 1)[ERROR]$(tput sgr0) Something went terribly wrong." 1>&2
fi

