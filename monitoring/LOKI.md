

# commands for debugging
- kubectl get pods -n monitoring
- kubectl get pod <pod-name> -n monitoring
- kubectl logs <pod-name> -n monitoring
- kubectl get pvc -n monitoring
- kubectl describe pod <pod-name> -n monitoring
- kubectl get events -n monitoring
- kubectl describe deployment flask-app-deployment -n monitoring
- kubectl get pods --all-namespaces
- kubectl delete pods -l app=flask-app -n monitoring
- kubectl delete deployment flask-app-deployment -n monitoring
- kubectl delete service flask-app-service -n monitoring

# install loki
- helm repo add grafana https://grafana.github.io/helm-charts
- helm repo list
- helm repo update
- helm search repo loki
- helm show values grafana/loki-stack > monitoring/values.yaml
- kubectl create namespace monitoring
- helm install --values monitoring/values.yaml loki grafana/loki-stack -n monitoring
- kubectl get pods -n monitoring
- export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=loki-grafana" -o jsonpath="{.items[0].metadata.name}")
- kubectl --namespace monitoring port-forward $POD_NAME 3000
- Enter in your browser: 127.0.0.1:3000
    - username: admin
    - password: kubectl get secret --namespace monitoring loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
- helm upgrade --values monitoring/values.yaml loki grafana/loki-stack -n monitoring