#!/usr/bin/env bash

MSG=$1
NODE=$2
POD_CIDR=$3
API_ADV_ADDRESS=$4

echo "********** $MSG"
echo "********** $MSG"
echo "********** $MSG ->> Initializing Kubernetes Cluster"
echo "********** $MSG ->> Master Node $NODE"
echo "********** $MSG ->> kv-master-$NODE"
kubeadm init --pod-network-cidr "$POD_CIDR" --apiserver-advertise-address "$API_ADV_ADDRESS" | tee /vagrant/kubeadm-init.out

echo "********** $MSG"
echo "********** $MSG"
echo "********** $MSG ->> Configuring Kubernetes Cluster Environment"
echo "********** $MSG"
echo "********** $MSG"
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
mkdir -p /vagrant/.kube
cp -i /etc/kubernetes/admin.conf /vagrant/.kube/config

#Configure the Calico Network Plugin
echo "********** $MSG"
echo "********** $MSG"
echo "********** $MSG ->> Configuring Kubernetes Cluster Calico Networking"
echo "********** $MSG ->> Downloading Calico YAML File"
echo "********** $MSG"
echo "********** $MSG"
wget -q https://docs.projectcalico.org/v3.10/manifests/calico.yaml -O /tmp/calico-default.yaml
#wget -q https://bit.ly/kv-lab-k8s-calico-yaml -O /tmp/calico-default.yaml
sed "s+192.168.0.0/16+$POD_CIDR+g" /tmp/calico-default.yaml > /tmp/calico-defined.yaml

echo "********** $MSG ->> Applying Calico YAML File"
echo "********** $MSG"
echo "********** $MSG"
kubectl apply -f /tmp/calico-defined.yaml
rm /tmp/calico-default.yaml /tmp/calico-defined.yaml
echo "KUBELET_EXTRA_ARGS=--node-ip=10.8.8.1$NODE" > /etc/default/kubelet

