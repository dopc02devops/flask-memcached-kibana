
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
# glusterfs-server
#####################
- Activate venv
    - source venv/bin/activate
    - cd ansible
    - ansible-playbook storage/install_glusterfs.yaml
    - check service status: sudo systemctl status glusterd
    - service will exit because it has not been configured to share
    - start service
        - sudo systemctl start glusterd
- We installed gluster on 2 ubuntu 20.04 nodes
- We need to now group them into a storage pool so they can communicate with each other
- Ensude gluster volume folder created on both nodes
    - sudo ls -l /gluster
    - edit hosts files and add ip addresses of both servers
        - sudo vim /etc/hosts
          - server1
            127.0.0.1   server1
            server2PublicIP   server2
          - server2
            127.0.0.1   server2
            server1PublicIP   server1
          - client
            server1PublicIP   server1
            server2PublicIP   server2
            
            server1PublicIP server1
    - edit client machine hosts file, it should be able to ping both glusterfs machines
        - ping server1
          ping server2
- We now need to group them together to form a single storage pool
    - run below command on server1 machine
      - sudo gluster peer probe server2
      - sudo gluster peer status
- We need create volume
    - create replicated volume
        - sudo gluster volume create myvolume replica 2 server1:/gluster/brick1 server2:/gluster/brick1
        - the warning is because we have 2 replicas, when creating highly available clusters, its usually with odd
          numbers eg 3, 5, 7
        - sudo gluster volume create myvolume replica 2 server1:/gluster/brick1 server2:/gluster/brick1 force
      - create distributed volume
        - sudo gluster volume create myvolume2 server1:/gluster/brick2 server2:/gluster/brick2 force
        - sudo gluster volume start myvolume
- We need to mount volume on client 
    - verify mount dir exist
        - sudo ls -l /mount/myvolume
        - sudo mount -t glusterfs server2:/myvolume /mount/myvolume
        - sudo mount | grep volume
- Navigate to /mount/myvolume
    - create file: touch example.txt
    - verify example.txt exist in both bricks
    - sudo gluster volume start myvolume2
- Commands
    - gluster volume list
    - sudo gluster volume stop myvolume
    - sudo gluster volume status myvolume
    - sudo gluster volume delete myvolume
    - sudo mount -t nfs <server>:/<volume_name> <mount_point>
    - sudo ls -la /var/log/glusterfs (log dir)
    - sudo cat /var/log/glusterfs/bricks/gluster-brick1.log
    - sudo tail -f /var/log/glusterfs/mount-myvolume.log
    - sudo gluster peer status
    - sudo gluster volume info myvolume
    - sudo gluster volume heal myvolume full
    - sudo gluster volume heal myvolume full
    - sudo gluster volume set myvolume cluster.self-heal-daemon on
    - sudo gluster volume set myvolume cluster.read-subvolume client


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
      