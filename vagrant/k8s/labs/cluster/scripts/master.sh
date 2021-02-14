#!/usr/bin/env bash

MSG=$1
NODE=$2
POD_CIDR=$3
API_ADV_ADDRESS=$4

echo "********** $MSG"
echo "********** $MSG"
echo "********** $MSG ->> Initializing Kubernetes Cluster"
echo "********** $MSG ->> Master Node $NODE"
echo "********** $MSG ->> bt-master-$NODE"
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
sed "s+192.168.0.0/16+$POD_CIDR+g" /tmp/calico-default.yaml > /tmp/calico-defined.yaml

echo "********** $MSG ->> Applying Calico YAML File"
echo "********** $MSG"
echo "********** $MSG"
kubectl apply -f /tmp/calico-defined.yaml

# The coredns Pod is only installed after a successful Pod network add-on (calico) install.
#RES=$(awk '/coredns/' <<< "$(kubectl get pods -n kube-system)")
#if [ -z "$RES" ]
#then
#    echo "********** $MSG"
#    echo "********** $MSG ->> Calico Pod network add-on was not properly installed, aborting..."
#    echo "********** $MSG"
#    exit 1
#elif [ "$(awk 'NR==1 { print $3 }' <<< "$RES")" != Running ]
#then
#    echo "********** $MSG"
#    echo "********** $MSG ->> Calico Pod network add-on was installed but is not in the Running state, aborting..."
#    echo "********** $MSG"
#    exit 1
#fi

rm /tmp/calico-default.yaml /tmp/calico-defined.yaml
echo "KUBELET_EXTRA_ARGS=--node-ip=10.8.8.1$NODE" > /etc/default/kubelet

systemctl daemon-reload
systemctl restart kubelet

