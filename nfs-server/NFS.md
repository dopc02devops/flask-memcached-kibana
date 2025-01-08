

# install nfs server
- helm repo add nfs-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
- helm repo update
- kubectl apply -f nfs-server/nfs.yaml
- helm install nfs-provisioner nfs-provisioner/nfs-subdir-external-provisioner \
  --namespace storage \
  --set nfs.server=nfs-server.storage.svc.cluster.local \
  --set nfs.path=/nfsshare
- helm list -n storage
- kubectl get pvc -n storage
- kubectl get pods -n storage
- kubectl delete deployment nfs-server -n storage
- helm delete nfs-provisioner -n storage
- kubectl delete deployment nfs-server -n storage
- kubectl delete storageclass nfs-provisioner
- kubectl delete pvc --all -n storage
- kubectl delete pods --all -n storage