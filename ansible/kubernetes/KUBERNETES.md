
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
    - ansible-playbook install_dependencies.yaml
    - ansible-playbook init_kube_master.yaml
    - ansible-playbook init_kube_workers.yaml
    - Login to master node with kube_user and run below commands
      - kubectl get nodes
      - kubectl get all -A
      - kubectl label nodes [Replace with ip from get nodes command] node-role.kubernetes.io/worker=worker
        kubectl label nodes [Replace with ip from get nodes command] node-role.kubernetes.io/worker=worker