
cd kibana

- filebeat: collects all logs from pods, sends them to logstash
- logstash: aggregades all logs, sends them to elasticsearch
- elasticsearch: stores and indexes all logs, sends them to kibana
- kibana; visualize logs in ui

#############
Add repo
#############
helm repo add elastic https://helm.elastic.co
helm repo update
helm search repo elastic

#############
Configurations
#############
source: https://medium.com/@davis.angwenyi/how-to-install-elastic-search-using-helm-into-kubernetes-de1fb1011076
helm show values elastic/filebeat > filebeat_values.yaml
helm show values elastic/logstash > logstash_values.yaml
helm show values elastic/elasticsearch > elasticsearch_values.yaml
helm show values elastic/kibana > kibana_values.yml

#############
Installation
#############
kubectl create namespace monitoring
helm install elasticsearch elastic/elasticsearch -f elasticsearch_values.yaml -n monitoring
helm install logstash elastic/logstash -f logstash_values.yaml -n monitoring
helm install kibana elastic/kibana -f kibana_values.yml -n monitoring
helm install filebeat elastic/filebeat -f filebeat_values.yaml -n monitoring
helm upgrade

#############
Uninstall
#############
helm uninstall filebeat -n monitoring
kubectl delete configmap kibana-kibana-helm-scripts -n monitoring

kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl port-forward svc/kibana-kibana 8000:5601 -n monitoring
kubectl get secrets -n monitoring
kubectl get secret elasticsearch-master-credentials -n monitoring -o yaml
echo "MUh0aUExVnRCNFdjdGh5Wg==" | base64 --decode
kubectl delete all --all -n monitoring
kubectl logs elasticsearch-master-0 -n monitoring --previous | grep error


