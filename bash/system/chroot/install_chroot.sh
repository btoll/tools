#!/bin/bash
# Run as root!

if [ $EUID -ne 0 ]; then
    echo -e "[ERROR] This script must be run as root!" 1>&2
    exit 1
fi

(
    # Dependencies.
    apt-get install schroot debootstrap

    # Create the dir where the jail is installed.
    mkdir /var/chroot

    # Create a config entry for the jail.
    echo -e "\n[foo]\ndescription=Foo\nlocation=/var/chroot\npriority=3\nusers=btoll\ngroups=sbuild\nroot-groups=root\n" >> /etc/schroot/schroot.conf

    # Finally, create the jail itself.
    # Note that to create the jail from a local iso that it needs Release.gpg.
    # sudo curl -O http://ftp.debian.org/debian/dists/jessie/Release.gpg
    # I.e., debootstrap jessie /var/chroot file:///home/btoll/debian-8_2_0.iso
    debootstrap jessie /var/chroot/ http://ftp.debian.org/debian

    # Copy over the shell script to continue the install from inside the jail.
    cp setup_chroot.sh /var/chroot
) &

echo "[INFO] Installing the chroot will take several minutes."

