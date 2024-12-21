
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
    - Login to master node with kube_user and run below commands
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
    - ansible-playbook install_dashboard.yaml
    - Run command on shell (localhost)
    - ssh -L 8001:127.0.0.1:8001 kube_user@master_ip
    kubectl proxy
    - Navigate to the dashboard page from a web browser on your local machine
    - http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/


#####################
# Nfs-server
#####################
- Provides shared file access to clients over a network.
  Enables users and systems to access files stored on the server as if they were stored locally
- Install nfs-server
    - run: sudo systemctl status nfs-server
    - It exited because we have not configured anything for the server to share
    - nothing in exports dir
- We created as our export mount
    - nfs_export_path: "/k8mount"
- Login to ur server and run below command
    - sudo systemctl status nfs-server
    - server will not exit because exports directory has shared directory configured
    - /etc/exports is empty indicating we have not shared anything
    - The /etc/exports file is the configuration file for the NFS server, where the directories to be exported and their 
      associated permissions are defined.
    - cat /etc/exports and u will see our shared directory
        - /k8mount *(rw,sync,no_subtree_check,no_root_squash)
            - *: Denotes that the NFS export is accessible by any client
            - rw: Provides read-write access to the NFS share
            - sync: Ensures changes are committed to disk before a write request is acknowledged
            - no_subtree_check: Disables subtree checking for performance and reliability reasons
            - no_root_squash: Allows root users on client machines to retain root privileges on the NFS share, 
              which can be a security risk if not managed carefully
- export: sudo exportfs -r
- verify export: sudo exportfs -v
- restart server: sudo systemctl restart nfs-server
- Install nfs-client on server
    - run: showmount ip
- make mount dir on client
    - sudo mkdir /nfs
      sudo mkdir /nfs/mount
- create mount
    - sudo mount 35.179.163.33:/k8mount /nfs/mount
    - run: df -h
        - 35.179.163.33:/k8mount  6.8G  4.1G  2.7G  61% /nfs/mount (Local dir is mounted on nfs dir)
        - create text file on nfs dir (/k8mount)
        - cd to /nfs/mount and do an ls -ls
      