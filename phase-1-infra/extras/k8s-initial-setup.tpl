#!/bin/bash
sudo hostnamectl set-hostname "${hostname}"

# Step 1. INSTALL CRI-O AS A CONTAINER RUNTIME

# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
sudo mkdir -p -m 755 /etc/apt/keyrings

# Install the important CRI-O packages
sudo apt-get update -y
sudo apt-get install -y software-properties-common gpg curl apt-transport-https ca-certificates 

# Add a respository of crio
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/${crio_version}/deb/Release.key | \
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/${crio_version}/deb/ /" | \
    tee /etc/apt/sources.list.d/cri-o.list

# Install cri-o
sudo apt-get update -y
sudo apt-get install -y cri-o
sudo chmod 666 /var/run/crio/crio.sock

# Enable and start cri-o
sudo systemctl daemon-reload
sudo systemctl enable crio --now
sudo systemctl start crio.service

# Install crictl 
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${crictl_version}/crictl-${crictl_version}-linux-amd64.tar.gz
sudo tar zxvf crictl-${crictl_version}-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-${crictl_version}-linux-amd64.tar.gz


# STEP 2. INSTALL KUBEADM & KUBECTL on all nodes

# Update packages and their versions
sudo apt-get update -y

# Download the public signing key for the Kubernetes v1.32 package repositories
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${kubernetes_version}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version
sudo apt-get update -y
sudo apt-get install -y kubelet=${k8s_cluster_version} kubeadm=${k8s_cluster_version} kubectl=${k8s_cluster_version}
sudo apt-mark hold kubelet kubeadm kubectl

