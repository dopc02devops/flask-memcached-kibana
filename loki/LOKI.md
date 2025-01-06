

# https://grafana.com/docs/loki/latest/setup/install/helm/
# install loki using docker-compose localhost
- cd loki
- docker-compose up -d

# Components
- Loki: Access Loki at http://localhost:3100
    Loki is a log aggregation system developed by Grafana Labs
    It collects, stores, and indexes logs from various sources
    Loki indexes metadata such as labels (e.g., application name, environment)
    This makes Loki more lightweight and cost-effective than traditional log systems like Elasticsearch
    Loki integrates seamlessly with Grafana for querying and visualizing logs

- Grafana: Access Grafana at http://localhost:3000
    Grafana is an open-source visualization and analytics platform
    It integrates with Loki to query and visualize logs
    Grafana also supports metrics (e.g., Prometheus) and traces (e.g., Jaeger or Tempo)
    It is a powerful observability tool

- Promtail: Logs from /var/log on your host should be sent to Loki
    Promtail is a log collection agent that ships logs to Loki
    It works similarly to log shippers like Fluentd, Logstash, or Filebeat
    Reads logs from files or other sources (e.g., /var/log)
    Adds labels to logs to categorize them (e.g., job: web, host: server1)
    Sends the logs to Loki for storage and analysis
- Prometheus:
    Prometheus collects metrics from (e.g., Loki, Promtail, Grafana, or your application).
    It enables monitoring and alerting for your system by analyzing the metrics

# Verify the setup:
    Grafana UI: Open http://localhost:3000 (login: admin/admin)
    Prometheus UI: Open http://localhost:9090 to view Prometheus
    Loki readiness prope: http://localhost:3100/ready
    Navigate to Configuration → Data Sources.
        Select Prometheus and set the URL to http://prometheus:9090
        Select loki and set url to http://localhost:3100

# Add Data Source for Prometheus and Loki
- create below directory structure
.
├── docker-compose.yml
├── loki-config.yaml
├── prometheus/
│   └── prometheus.yml
├── grafana/
│   └── provisioning/
│       └── datasources/
│           └── datasources.yml
└── promtail-config.yaml

# install grafana ansible
- cd ansible
- ansible-playbook grafana/install_grafana.yaml
- ssh -L 3000:localhost:3000 kube_user@ip
- ssh -f -N -L 3000:localhost:3000 kube_user@ip (run in back-ground)
- http://localhost:3000 to access grafana
# Install kubernetes dashboard
- cd ansible k8-dashboard/create_dashboard.yaml
- copy token
- ssh -L 8001:localhost:8001 kube_user@ip

docker-compose -f docker-compose.dashboard.yml up -d
kubectl -n kubernetes-dashboard create token admin-user
http://localhost:8001