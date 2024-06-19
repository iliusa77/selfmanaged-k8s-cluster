#!/bin/bash

function installAndConfigurePrerequisites {
  apt update && \
  apt -y upgrade && \
  apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
}

#swap disabling
swapoff -a
sed -i 's/\/swap.img/#\/swap.img/g' /etc/fstab

#modules 
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

systemctl stop ufw && systemctl disable ufw

#cri-o installation
export OS=xUbuntu_22.04
export CRIO_VERSION=1.25
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"| tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"| tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key add -
apt update && apt -y install cri-o cri-o-runc cri-tools
systemctl start crio && systemctl enable crio

#kubernetes installation
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt update && apt -y install kubelet kubeadm kubectl && apt-mark hold kubelet kubeadm kubectl

host_name=$(hostname)
if [ $host_name = "k8s-master-node" ]; then
  kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint "192.168.56.10:6443" >>/home/vagrant/kubeadm_join_worker_nodes.sh 2>&1
  mkdir -p /home/vagrant/.kube
  sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
  sudo chown -R vagrant:vagrant /home/vagrant
fi

#in worker nodes need to run
#sudo kubeadm join 192.168.56.10:6443 --token unmu8e.mwjv1niet1yxfxgb \
#  --discovery-token-ca-cert-hash sha256:a2ea320fafe1b4cadb27fff084267348570cf23c9003ba4589492a9051d3cabb
