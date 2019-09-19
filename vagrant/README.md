## Description

This example will create a load balancer in front of three [nginx] web servers.  The load balancer will distribute requests in a round robin fashion.

In turn, the nginx web server on each node is configured as a reverse proxy and will proxy its traffic to an instance of the [Python simple HTTP server] listening on port 1234.

The web servers are using [basic access authentication].  Please don't use in production, as it doesn't provide any confidentiality.

## Installation

The host machine needs to have the following packages installed:

- [VirtualBox]
- [Vagrant]
- [Ansible]

On a Debian-based OS, this can simply be done using `apt`.  Keep in mind that the package may not be the latest version (available on the vendor's site).

The versions used in this demo are:

- VirtualBox 5.2.18
- Vagrant 2.2.5
- Ansible 2.6.5

> There is a provisioner called [`ansible_local`] which does not necessitate the need to install Ansible on the host system, but this demo does not use it.

## Housekeeping

Create the directory that will house the demo and extract the files from the archive.  Listing out the directory should reveal the following files and directories:

- playbook.yml
- README.md
- roles/
    + common/
    + lb/
    + web/
- Vagrantfile
- vagrant.up

Issue the following command to download the box (image) used in the demo:

```
vagrant box add https://app.vagrantup.com/generic/boxes/debian9
```

> It is not necessary to issue the command `vagrant init` since the demo includes its own `Vagrantfile`.

## Creating and Provisioning

Create the nodes and provision the servers by running the command:

```
vagrant up
```

This will create the four nodes on its own private network and accessible from the host via port forwarding:

```
                    +----------------+
                    +      host      +
                    + 127.0.0.1:4444 +
                    +----------------+
                           |
============================================================
                           |
                    +---------------+
                    +      lb1      +
                    + 10.0.0.10:80  +
                    +---------------+
                   /       |         \
                  /        |          \
                 /         |           \
+---------------+          |            +---------------+
+     node1     +          |            +     node3     +
+   10.0.0.11   +          |            +   10.0.0.13   +
+---------------+   +---------------+   +---------------+
                    +     node2     +
                    +   10.0.0.12   +
                    +---------------+
```

## Running the Demo

Point the browser at `http://localhost:4444`.  You will be asked for authorization credentials:

- user = `algorand`
- pass = `test`

At this point, the request, forwarded into the internal private network and send to the first node by the load balancer, will have the Python simple server simply list out a directory.  Refreshing will cycle through the machines `node1`, `node2` and `node3`.

[nginx]: https://nginx.org/
[Python simple HTTP server]: https://docs.python.org/2/library/simplehttpserver.html
[basic access authentication]: https://en.wikipedia.org/wiki/Basic_access_authentication
[VirtualBox]: https://www.virtualbox.org/
[Vagrant]: https://www.vagrantup.com/
[Ansible]: https://www.ansible.com/
[`ansible_local`]: https://www.vagrantup.com/docs/provisioning/ansible_local.html

