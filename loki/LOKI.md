

# https://grafana.com/docs/loki/latest/setup/install/helm/
# install loki using helm
- cd loki
- run below to download loki-local-config.yaml and promtail-docker-config.yaml
wget https://raw.githubusercontent.com/grafana/loki/v3.0.0/cmd/loki/loki-local-config.yaml -O loki-config.yaml
wget https://raw.githubusercontent.com/grafana/loki/v3.0.0/clients/cmd/promtail/promtail-docker-config.yaml -O promtail-config.yaml
- run below command to start docker 
docker run --name loki -d -v $(pwd):/mnt/config -p 3100:3100 grafana/loki:3.2.1 -config.file=/mnt/config/loki-config.yaml
docker run --name promtail -d -v $(pwd):/mnt/config -v /var/log:/var/log --link loki grafana/promtail:3.2.1 -config.file=/mnt/config/promtail-config.yaml