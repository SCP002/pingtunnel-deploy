# PingTunnel Server Installer

This script installs [PingTunnel](https://github.com/esrrhs/pingtunnel) on your server and configures it to run as a
background service in **server mode** using `systemd`.

## Differences with the upstream repository

* Added `-nolog 1` to command start arguments
* Ask for authorization mode (only `-key` or `-encrypt` and `-encrypt-key`)
* Ask for forward proxy address (add `-forward` if specified)

## Features

* Detects OS and architecture automatically  
* Downloads the **latest version** of PingTunnel  
* Installs it into `/opt/pingtunnel`  
* Creates a `systemd` service (`pingtunnel.service`)  
* Starts and enables the service on boot  

---

## Installation

Run this command to install PingTunnel server:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/SCP002/pingtunnel-deploy/main/installer.sh)
```

## Service Check

```bash
systemctl status pingtunnel
```
