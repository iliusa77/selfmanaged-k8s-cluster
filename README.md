## Fully sefmanaged Kubernetes cluster

This repository provides installation and configuration Kubernetes cluster (1 master node and 2 worker nodes) in Ubuntu 22.04 using Vagrant or Terraform

Kubernetes entities which will deployed:
- Kubernetes 1.29.6
- CRI-O (https://cri-o.io/)
- Flannel (https://github.com/flannel-io/flannel)

### Vagrant

1. Create Vagrant VMs stack
```
vagrant up && vagrant provision
...
kubeadm join 192.168.56.10:6443 --token wtvz68.rzpvd2hfvvgrmsed \
    vm1:        --discovery-token-ca-cert-hash sha256:46a5902e9da69d0c6506434c94f71477865c8c3c84bac2a1e7b67a109a6397ba
```

### Kubernetes

2. Go to master node and execute
```
cat /home/vagrant/kubeadm_join_worker_nodes.sh 
...
You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:

  kubeadm join 192.168.56.10:6443 --token rkn3yj.zfqy8b4o6qxc6d68 \
        --discovery-token-ca-cert-hash sha256:c9dd22c1561c8895279c4be5aaad0f2dff4f854636758503277dd39c15b40864 \
        --control-plane 

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.56.10:6443 --token rkn3yj.zfqy8b4o6qxc6d68 \
        --discovery-token-ca-cert-hash sha256:c9dd22c1561c8895279c4be5aaad0f2dff4f854636758503277dd39c15b40864 
```


3. Go to worker nodes and execute the following command:
```
sudo kubeadm join 192.168.56.10:6443 --token rkn3yj.zfqy8b4o6qxc6d68 \
  --discovery-token-ca-cert-hash sha256:c9dd22c1561c8895279c4be5aaad0f2dff4f854636758503277dd39c15b40864 
```

You will get output
```
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

5. Go to masker node, copy `$HOME/.kube/config` content, go to worker nodes and do:
```
mkdir -p $HOME/.kube
vim $HOME/.kube/config
# put here the content of $HOME/.kube/config from master node
```

6. Get k8s nodes in all Vagrant VMs
```
vagrant@k8s-master-node:~$ kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
k8s-master-node     Ready    control-plane   71m   v1.29.6
k8s-worker-node-1   Ready    <none>          68m   v1.29.6
k8s-worker-node-2   Ready    <none>          68m   v1.29.6

vagrant@k8s-worker-node-1:~$ kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
k8s-master-node     Ready    control-plane   71m   v1.29.6
k8s-worker-node-1   Ready    <none>          69m   v1.29.6
k8s-worker-node-2   Ready    <none>          68m   v1.29.6

vagrant@k8s-worker-node-2:~$ kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
k8s-master-node     Ready    control-plane   72m   v1.29.6
k8s-worker-node-1   Ready    <none>          69m   v1.29.6
k8s-worker-node-2   Ready    <none>          69m   v1.29.6
```

7. Go to master node and install Flannel addon
```
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
```

8. Check Flannel pods
```
vagrant@k8s-master-node:~$ kubectl get po -n kube-flannel
NAME                    READY   STATUS             RESTARTS        AGE
kube-flannel-ds-4278z   1/1     Running            0               60m
kube-flannel-ds-hc258   0/1     CrashLoopBackOff   14 (12s ago)    46m
kube-flannel-ds-n6glw   0/1     Error              14 (5m9s ago)   46m
```


### Terraform (manual)
Generate SSH keys pair
```
ssh-keygen -t rsa -b 4096 -f ./ec2-docker-ssh-key
chmod 400 ec2-docker-ssh-key
```


Create infra
```
terraform init

terraform plan
var.profile
  AWS credentials profile you want to use

  Enter a value: default

terraform apply -auto-approve
var.profile
  AWS credentials profile you want to use

  Enter a value: default

instance_1_private_ip = ""
instance_1_public_ip = ""
instance_2_private_ip = ""
instance_2_public_ip = ""
instance_3_private_ip = ""
instance_3_public_ip = ""
```

Configure Kubernetes
```
# master node
ssh ubuntu@<instance_1_public_ip> -i ec2-docker-ssh-key
sudo hostnamectl set-hostname k8s-master-node

sudo kubeadm init --control-plane-endpoint "<instance_1_private_ip>:6443" --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

...
You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:

  kubeadm join <instance_1_private_ip>:6443 --token 7muies.8oim8k4m0ngtzbhd \
        --discovery-token-ca-cert-hash sha256:f4351047a18ed0e984283f0e83e10c1d96d5e8be9a51ef9c790c8831e08366b3 \
        --control-plane 

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join <instance_1_private_ip>:6443 --token 7muies.8oim8k4m0ngtzbhd \
        --discovery-token-ca-cert-hash sha256:f4351047a18ed0e984283f0e83e10c1d96d5e8be9a51ef9c790c8831e08366b3 

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# worker node 1
ssh ubuntu@<instance_2_public_ip> -i ec2-docker-ssh-key
sudo hostnamectl set-hostname k8s-worker-node-1
sudo kubeadm join <instance_1_private_ip>:6443 --token 7muies.8oim8k4m0ngtzbhd \
    --discovery-token-ca-cert-hash sha256:f4351047a18ed0e984283f0e83e10c1d96d5e8be9a51ef9c790c8831e08366b3 

mkdir -p $HOME/.kube
vim $HOME/.kube/config

# worker node 2
ssh ubuntu@<instance_3_public_ip> -i ec2-docker-ssh-key
sudo hostnamectl set-hostname k8s-worker-node-2
sudo kubeadm join <instance_1_private_ip>:6443 --token 7muies.8oim8k4m0ngtzbhd \
    --discovery-token-ca-cert-hash sha256:f4351047a18ed0e984283f0e83e10c1d96d5e8be9a51ef9c790c8831e08366b3 

mkdir -p $HOME/.kube
vim $HOME/.kube/config
```

Flannel in AWS (EC2)
```
# master node
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml

kubectl get po -n kube-flannel
NAME                    READY   STATUS    RESTARTS   AGE
kube-flannel-ds-h8d2s   1/1     Running   0          13s
kube-flannel-ds-tgpsn   1/1     Running   0          13s
kube-flannel-ds-xbhtg   1/1     Running   0          13s
```

Test deploy in AWS (EC2)
```
# worker node
kubectl apply -f nginx_deployment.yaml

kubectl get deploy,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
deployment.apps/nginx-deployment   2/2     2            2           95s   nginx        nginx:1.16.1   app=nginx

NAME                                    READY   STATUS    RESTARTS   AGE   IP           NODE                NOMINATED NODE   READINESS GATES
pod/nginx-deployment-848dd6cfb5-c2pch   1/1     Running   0          95s   10.244.2.2   k8s-worker-node-2       <none>           <none>
pod/nginx-deployment-848dd6cfb5-vdmx5   1/1     Running   0          95s   10.244.1.2   k8s-worker-node-1       <none>           <none>
ubuntu@k8s-worker-node-1:~$ 
```

Terraform destroy (infra cleanup)
```
terraform destroy -auto-approve
var.profile
  AWS credentials profile you want to use

  Enter a value: default
```

### Terraform (auto with Github Actions pipeline)
Generate SSH keys pair
```
ssh-keygen -t rsa -b 4096 -f ./ec2-docker-ssh-key
chmod 400 ec2-docker-ssh-key
```

Comment profile variable in `providers.tf`
```
provider "aws" {
  #profile    = "${var.profile}" 
}
```

Comment profile and region variables in `vars.tf`
```
#variable "profile" {
#    description = "AWS credentials profile you want to use"
#}

#variable "region" {
#  default = "eu-west-2"
#}
```

Define ec2_availability_zones in `vars.tf`
```
variable "ec2_availability_zones" {
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}
```



source: https://timeweb.cloud/tutorials/kubernetes/kak-ustanovit-i-nastroit-kubernetes-ubuntu

