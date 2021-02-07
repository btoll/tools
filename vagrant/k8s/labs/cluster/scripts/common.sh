#!/usr/bin/env bash

MSG=$1

echo "********** $MSG"
echo "********** $MSG"
echo "********** $MSG ->> Adding Kubernetes and Docker-CE Repo"
echo "********** $MSG"
echo "********** $MSG"
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install apt-transport-https ca-certificates curl software-properties-common

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

### Kubernetes Repo
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

echo "********** $MSG"
echo "********** $MSG"
echo "********** $MSG ->> Updating Repositories"
echo "********** $MSG"
echo "********** $MSG"
apt-get update

echo "********** $MSG"
echo "********** $MSG"
echo "********** $MSG ->> Installing Required & Recommended Packages"
echo "********** $MSG"
echo "********** $MSG"
apt-get install -y avahi-daemon libnss-mdns traceroute htop httpie bash-completion docker-ce=5:20.10.2~3-0~ubuntu-bionic kubeadm kubelet kubectl

# Setup Docker daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker

