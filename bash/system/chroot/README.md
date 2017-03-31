# Installing chroot

## Schroot configs

In `/etc/schroot/default/copyfiles`:
```
/etc/resolv.conf
/etc/apt/sources.list
/srv/setup_chroot.sh
```

In `/etc/schroot/default/fstab`, I commented out the `/home` mount point.

## sshd_config
```
Match group codeshare
        ChrootDirectory /srv/chroot/codeshare
        X11Forwarding no
        AllowTcpForwarding no
```

### Installing NodeJS
NodeJS is tarred up using zx compression tool:
- sudo apt-get install xz-utils
- tar xvJf xxx.zx

#### If receiving a "No such file or directory" error when executing:

The node binary is a 32-bit ELF, but it's a 64 bit OS.

```
file /path/to/node
ldd /path/to/node
```

https://superuser.com/questions/344533/no-such-file-or-directory-error-in-bash-but-the-file-exists

Specifically:
```
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install --reinstall libc6-i386
sudo apt-get install "libstdc++6:i386"
```

