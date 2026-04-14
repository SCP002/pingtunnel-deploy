# PingTunnel Server Installer

This script installs [PingTunnel](https://github.com/esrrhs/pingtunnel) on your server and configures it to run as a
background service.

## Differences with the upstream repository

* Added `-nolog 1` since systemd will create logs automatically.
* Ask for `-encrypt` (default is `aes256`).
* Ask for `-encrypt-key`.
* Ask for `-icmp_l` (default is `0.0.0.0`).
* Ask for `-forward` (optional).

## Installation

Run this command to install PingTunnel server:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/SCP002/pingtunnel-deploy/main/installer.sh)
```

## Service Check

```bash
systemctl status pingtunnel
```
