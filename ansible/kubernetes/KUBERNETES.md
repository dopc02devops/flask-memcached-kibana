
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
kubectl config set-cluster my-cluster --server=https://18.134.172.100:6443
kubectl config view

# Set context
kubectl config set-context my-cluster --cluster=my-cluster --user=kubernetes-admin --namespace=stage

kubeadm token create --print-join-command

# if u see errors when joining due to left over config
    - sudo kubeadm reset
      sudo rm -f /etc/kubernetes/kubelet.conf
      sudo rm -f /etc/kubernetes/pki/ca.crt
      sudo rm -rf /etc/kubernetes/pki/*
      sudo systemctl stop kubelet


