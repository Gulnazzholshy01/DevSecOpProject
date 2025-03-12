### Monitoring with Prometheus and Grafana
##### Step 1. Setting up Prometheus
1. SSH to the monitor vm and create a system service file for Prometheus
```sudo nano /etc/systemd/system/prometheus.service```

Include the following settings:
```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

2.   Then reload the system:
```
sudo systemctl daemon-reload
```

3. Start and Enable Prometheus
```
sudo systemctl enable prometheus
sudo systemctl start prometheus
```

4. Check the status 
```
systemctl status prometheus
```

##### Step 2. Setting up Grafana
1. Also start and enable Grafana Server
```
sudo /bin/systemctl start grafana-server
sudo /bin/systemctl enable grafana-server
```
1. Check the status of Grafana server
```
 systemctl status  grafana-server
```

3. Now access the web UI of Grafana http://grafana_server:3000, login as default admin user (password is also admin), change the password


##### Step 3. Setting up  BlackBox Exporter
1. Install BlackBox Exporter
```
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.26.0/blackbox_exporter-0.26.0.linux-amd64.tar.gz
tar -xvf blackbox_exporter*.tar.gz
rm -rf blackbox_exporter*.tar.gz

```
2. Start BlackBox Exporter in background (It runs on port 9115 by default)
```
cd blackbox_exporter*
./blackbox_exporter &
```
3. Add BlackBox Experter configuration to /etc/prometheus.yml under scrape_configs:
- include your apps to monitor under targets
- change blackbox_exporter url to real url in replacements
```
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]  # Look for a HTTP 200 response.
    static_configs:
      - targets:
        - http://prometheus.io    # Target to probe with http.
        - http://3.147.127.141:31433
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 3.148.117.48:9115  # The blackbox exporter's real hostname:port.
```
4. Reload systemd daemon and restart prometheus
```
sudo systemctl daemon-reload
sudo systemctl restart prometheus
```

##### Step 4. Create Prometheus Dashboard in Grafana

1. Add Prometheus as Data Source in Grafana
Grafana -> Connections -> Data Sources -> Add data source 
- Click Prometheus
- Add IP address of Prometheus in Connection block 

2. Create a dashboard in Grafana
- Search for BlackBox Grafana Dashboard id (should be 7587)
- Click Prometheus as a Data Source 

##### Step 5. Monitor Jenkins with Grafana
1. Install Prometheus Metrics in Jenkins Plugins
2. Download Node Exporter into Jenkins Server
```
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.0/node_exporter-1.9.0.linux-amd64.tar.gz

tar -xvf node_exporter*.tar.gz

rm -rf node_exporter*.tar.gz

cd node_exporter*
```
3. Start node_exporter in background mode (It runs on port 9100 by default)
```
./node_exporter &
```

4. Configure Prometheus in Jenkins
Manage Jenkins -> System -> Prometheus -> Check the metrics you want to monitor 

5. Update prometheus.yml in monitor server to include node_exporter
```
  - job_name: 'node_exporter'
    static_configs:
      - targets:
        - 18.226.133.13:9100  
  - job_name: 'jenkins'
    metrics_path: '/prometheus'
    static_configs:
      - targets:
        - 18.226.133.13:8080    
```

6. Search for Node Exporter Grafana Dashboard to get the id (it should be 1860) then add dashboard

6. Search for Jenkins Grafana Dashboard to get the id (it should be 9964) then add dashboard
