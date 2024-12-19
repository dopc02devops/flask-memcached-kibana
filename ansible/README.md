
- Add hosts in file
- Configure ansible.cfg file
- Activate venv
    - source venv/bin/activate
    - cd ansible
- Create kube_user
    - ansible-playbook create_ec2_user.yaml
- Install kubernetes on ec2 instances
    - ansible-playbook install_dependencies.yaml
    - ansible-playbook init_kube_master.yaml
    - ansible-playbook init_kube_workers.yaml
    - Login to master node and run below commands
      - kubectl get nodes
      - kubectl get all -A
      - kubectl label nodes [Replace with ip from get nodes command] node-role.kubernetes.io/worker=worker
        kubectl label nodes [Replace with ip from get nodes command] node-role.kubernetes.io/worker=worker

- Install nfs-server
    - ansible-playbook install_nfs_server.yaml
    - ansible-playbook install_nfs_provisioner.yaml
    - Check if exist on file system
       - ls -l /k8mount
       - df -h /k8mount
- Create dashboard
    - Ansible/install_dashboard.yaml
    - Run command on shell (localhost)
    - ssh -L 8001:127.0.0.1:8001 kube_user@master_ip
    kubectl proxy
    - Navigate to the dashboard page from a web browser on your local machine
    - http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/