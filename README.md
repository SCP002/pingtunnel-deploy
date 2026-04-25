# Pingtunnel deploy script

This script installs [Pingtunnel](https://github.com/esrrhs/pingtunnel) on your server and configures it to run as a
background service.

## Differences with the upstream repository

* Added `-nolog 1` since systemd will create logs automatically.
* Ask for `-encrypt` (default is `aes256`).
* Ask for `-encrypt-key`.
* Ask for `-icmp_l` (default is `0.0.0.0`).
* Ask for `-forward` (optional).

## Installation

Run this command to install Pingtunnel server:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/SCP002/pingtunnel-deploy/main/installer.sh)
```

## Service check

```bash
systemctl status pingtunnel
```

## Android client setup

* Install [Termux](https://github.com/termux/termux-app)
* In Termux, run:

```bash
termux-wake-lock
pkg update
pkg upgrade
pkg install --yes curl unzip net-tools
curl -fLO https://github.com/esrrhs/pingtunnel/releases/latest/download/pingtunnel_android_arm64.zip
unzip pingtunnel_android_arm64.zip
chmod +x ./pingtunnel
# See `EXTERNAL_ADAPTER_IP` with `ifconfig` command
./pingtunnel -type client -l :1090 -s SERVER_ADDRESS -icmp_l EXTERNAL_ADAPTER_IP -key KEY -nolog 1 -encrypt ENCRYPTION_MODE -encrypt-key ENCRYPTION_KEY -sock5 1 -s5user SOCKS_USER -s5pass SOCKS_PASSWORD
```

* Install [Exclave](https://github.com/dyhkwong/Exclave)
* In Exclave create a `SOCKS` config with address `127.0.0.1`, port `1090`, login as SOCKS_USER, password as SOCKS_PASSWORD.
* Select newly created profile and connect to it.
