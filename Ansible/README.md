


- Add hosts in file
- Configure ansible.cfg file
- ./Ansible/create_ec2_user.yaml
- Install kubernetes on ec2 instances
    - ./Ansible/install_dependencies.yaml
    - ./Ansible/init_kube_master.yaml
    - Login to master node and run below commands
      - kubectl get nodes
      - kubectl get all -A
- install nfs-server
    - ./Ansible/install_nfs_server.yaml
    - ./Ansible/install_nfs_provisioner.yaml
    - Check if exist on file system
       - ls -l /k8mount
       - df -h /k8mount