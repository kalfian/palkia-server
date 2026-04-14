## Prerequisite
- port 53 tcp and udp available
```bash
sudo lsof -i :53
```
- disable dnsmasq if enabled
```bash
sudo systemctl stop dnsmasq
sudo systemctl disable dnsmasq
```
