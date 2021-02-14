#!/usr/bin/env bash
# shellcheck disable=2091

MSG=$1
NODE=$2
NODE_HOST_IP=$((20+"$NODE"))
POD_CIDR=$3
API_ADV_ADDRESS=$4

echo "********** $MSG"
echo "********** $MSG"
echo "********** $MSG ->> Joining Kubernetes Cluster"
echo "********** $MSG ->> Worker Node $NODE"
echo "********** $MSG ->> bt-worker-$NODE"
echo "********** $MSG ->> Pod CIDR $POD_CIDR"
echo "********** $MSG ->> API address $API_ADV_ADDRESS"

# Extract and execute the kubeadm join command from the exported file.
$(< /vagrant/kubeadm-init.out grep -A 2 "kubeadm join" | sed -e 's/^[ \t]*//' | tr '\n' ' ' | sed -e 's/ \\ / /g')
echo "KUBELET_EXTRA_ARGS=--node-ip=10.8.8.$NODE_HOST_IP" > /etc/default/kubelet

systemctl daemon-reload
systemctl restart kubelet

