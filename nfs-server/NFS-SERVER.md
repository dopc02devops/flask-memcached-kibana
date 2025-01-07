


kubectl apply -f nfs-server/nfs-server.yaml
kubectl apply -f nfs-server/nfs-service.yaml
Let's create nfs-direct folder inside /exports directory of NFS server
    kubectl get pods -n storage
    kubectl exec -n storage nfs-server-7d698c4d5b-cq942 -- mkdir -p /exports/nfs-direct
    kubectl exec -n storage nfs-server-7d698c4d5b-cq942 -- mkdir -p /exports/pvc
    kubectl exec -n storage nfs-server-7d698c4d5b-cq942 -- ls /exports

# add pvc
kubectl apply -f nfs-server/nfs-pv.yaml
kubectl apply -f nfs-server/nfs-pvc.yaml
kubectl get pvc -n stage nfs-pvc
# delete
kubectl delete pods --all -n storage
