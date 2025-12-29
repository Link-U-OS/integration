echo "start uninstall prometheus"
sudo systemctl stop prometheus
sudo systemctl stop push_prometheus_metrics
sudo systemctl disable prometheus
sudo systemctl disable push_prometheus_metrics
echo "uninstall prometheus success"