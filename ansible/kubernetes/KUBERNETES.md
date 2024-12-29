
#####################
# install kubernetes
#####################
- Add hosts in file
- Configure ansible.cfg file
- Activate venv
    - source venv/bin/activate
    - cd ansible
- Create kube_user
    - ansible-playbook user/create_user.yaml
- Install kubernetes on ec2 instances
    - ansible-playbook kubernetes/install_dependencies.yaml
    - ansible-playbook kubernetes/init_kube_master.yaml
    - ansible-playbook kubernetes/init_kube_workers.yaml
    - Login to master node with kube_user and run below commands
      - kubectl get nodes
      - kubectl get all -A
      - kubectl label nodes [Replace with ip from get nodes command] node-role.kubernetes.io/worker=worker
        kubectl label nodes [Replace with ip from get nodes command] node-role.kubernetes.io/worker=worker

#####################
# initialize kubernetes
#####################
# We need to expose the external master node to be able to access our cluster externally
# We need to add our master to the certificate and re-initialise the cluster
sudo kubeadm init --apiserver-cert-extra-sans 18.134.172.100 --ignore-preflight-errors=NumCPU,Mem
You need to run this command to include the UBUNTU_AWS on the number of hosts on the certificate



# Set context
kubectl config set-context my-cluster --cluster=my-cluster --user=kubernetes-admin --namespace=stage

kubeadm token create --print-join-command

# if u see errors when joining due to left over config
    - sudo kubeadm reset
      sudo rm -f /etc/kubernetes/kubelet.conf
      sudo rm -f /etc/kubernetes/pki/ca.crt
      sudo rm -rf /etc/kubernetes/pki/*
      sudo systemctl stop kubelet
      kubectl config set-cluster kubernetes --server=https://18.134.172.100:6443
      sudo kubeadm init --apiserver-cert-extra-sans 18.134.172.100 --ignore-preflight- 
      errors=NumCPU,Mem
      kubectl config view

#####################
# cidr configuration
#####################
- Your Configuration:
VPC CIDR Block: 10.0.0.0/16
This means your entire VPC uses the IP range 10.0.0.0 to 10.0.255.255.
- Subnets:
cidrsubnet(aws_vpc.main.cidr_block, 8, count.index) dynamically divides the 
VPC's /16 block into smaller subnets
For a /16 VPC and 8 additional bits, the subnet mask becomes /24
Each subnet will have a range like 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24, etc., depending on count.index.
- Kubernetes Configuration:
podSubnet: 192.168.0.0/16
This does not overlap with your VPC or subnet CIDRs, as 192.168.0.0/16 is in an entirely different private IP range.
serviceSubnet: 10.96.0.0/12
This translates to the range 10.96.0.0 to 10.111.255.255.
- Conflict Analysis:
PodSubnet:
No conflict with your VPC or subnet CIDRs because it uses the 192.168.0.0/16 range, which is completely outside 
the 10.0.0.0/16 range.
ServiceSubnet:
This might overlap with your VPC or subnet CIDRs.
Your VPC uses 10.0.0.0/16, and some of your subnets are within this range (e.g., 10.0.0.0/24, 10.0.1.0/24).
The Kubernetes serviceSubnet (10.96.0.0/12) spans from 10.96.0.0 to 10.111.255.255.
Since this is outside the 10.0.0.0/16 range, no conflict occurs here.
- Conclusion:
You should not have conflicts based on the provided configuration. Here's why:

podSubnet (192.168.0.0/16) is outside your VPC range (10.0.0.0/16).
serviceSubnet (10.96.0.0/12) does not overlap with your VPC or subnets because it starts well after 10.0.0.0/16.
Recommendations:
Ensure your podSubnet and serviceSubnet configurations match the kubeadm-config.yaml setup during the kubeadm init process.
Document the IP ranges to avoid future overlaps if your network grows.

#####################
# explanation
#####################
The Kubernetes serviceSubnet (10.96.0.0/12) spans from 10.96.0.0 to 10.111.255.255.

The /12 Subnet Mask:
The /12 means that the first 12 bits are the network portion of the address, leaving the remaining 20 bits (32 - 12 = 20) for host addresses.
The subnet mask for /12 in binary looks like this:
11111111. 11110000. 00000000. 00000000

