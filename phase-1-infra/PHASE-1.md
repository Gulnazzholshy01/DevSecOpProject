***PHASE 1 - Infratructure Setup***

**Step 1. Create Kubernetes cluster with kubeadm on Amazon EC2 VMs.**

- **Step 1.1.**  Create 1 Master and 2 Worker nodes with correct SG rules for K8S Cluster. 

- **Step 1.2.** Install crio, crioctl, kubeadm, kubectl, kubelet on all nodes. (This part is handled by *user_data*. If you need a specific version of crio, crioctl or kubeadm components, please change it under *data.tf*). 
```
Note! Step 1.1, Step 1.2 are handled by Terraform code.
```

- **Step 1.3.** Disable swap [All nodes]. Should be disabled by default, if not check by running [All nodes]
```
free -h
```
- **Step 1.4.** Open required ports in the firewall (ideally firewall should be turned off). Check firewall status using [All Nodes]:
```
systemctl status firewalld
```
- **Step 1.5.** Enable iptables Bridged Traffic, run following commands  [All Nodes]
```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
```
- **Step 1.6.** Initialize Kubernetes cluster [Master Node]. 
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```
- **Step 1.7.** Configure Kubernetes Cluster [Master Node]
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
- **Step 1.8.** Join worker nodes to K8S cluster [Worker Nodes]
```
kubeadm join 172.31.12.45:6443 --token dx4fr7.inepc4ltnreo61pw \
	--discovery-token-ca-cert-hash sha256:ee96082cf53b50b7bb3437b419b5587e7f5ab30be30276ae4de119cd8a0b9323 
```

Upon completing Step 1.8, you should see kubernetes nodes when you run `kubectl get nodes` on Master Node, but nodes will be in `NotReady` status, because we have not set Network Plugin yet, which we will proceed with it in Step 1,9.

- **Step 1.9.** Install Calico Network Plugin for Pod Networking [Master Node]
```
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

- **Step 1.10.** Deploy Ingress Controller [Master Node]
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml
```

**Step 2. Create Docker Containers for SonarQube and Nexus.**

- **Step 2.1.** Create docker container for Sonarqube [Sonarqube VM]
```
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```

To connect the webpage of Sonarqube:
1. Navigate `public_ip_sonarqube_vm:9000`
2. After login in as admin, change password (initial user: admin, password: admin)

- **Step 2.2.** Create docker container for Nexus [Nexus VM]
```
docker run -d --name nexus -p 8081:8081 sonatype/nexus3 
```
To connect the webpage of Nexus:
1. Navigate `public_ip_nexus_vm:8081`
2. After login in as admin, change password

You can get initial admin password in docker container:
`docker exec -ti e7d346c88bb8 /bin/bash`, e7d346c88bb8 is a container ID where nexus is running
`cat sonatype-work/nexus3/admin.password`

**Step 3. Jenkins Setup**

To connect the webpage of Jenkins:
1. Navigate `public_ip_jenkins_vm:8080`
2. After login in as admin, change password

You can get initial admin password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

*** 
**Congratulations! Phase 1 ends here, proceed to Phase 2!**