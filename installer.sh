#!/bin/bash

set -e

# Detect OS
get_os() {
    os=$(uname | tr '[:upper:]' '[:lower:]')
    case "$os" in
    linux | darwin | freebsd | dragonfly | illumos | aix) echo "$os" ;;
    *)
        echo "Unsupported OS: $os"
        exit 1
        ;;
    esac
}

# Detect architecture
get_arch() {
    arch=$(uname -m)
    case "$arch" in
    x86_64) echo "amd64" ;;
    i386 | i686) echo "386" ;;
    armv7l | armv6l) echo "arm" ;;
    aarch64 | arm64) echo "arm64" ;;
    riscv64) echo "riscv64" ;;
    ppc64) echo "ppc64" ;;
    *)
        echo "Unsupported architecture: $arch"
        exit 1
        ;;
    esac
}

# Ensure unzip is available
ensure_unzip() {
    if ! command -v unzip >/dev/null 2>&1; then
        echo "Installing unzip..."
        if command -v apt >/dev/null 2>&1; then
            apt update && apt install -y unzip
        elif command -v yum >/dev/null 2>&1; then
            yum install -y unzip
        else
            echo "Please install unzip manually."
            exit 1
        fi
    fi
}

install_pingtunnel() {
    OS=$(get_os)
    ARCH=$(get_arch)
    FILE="pingtunnel_${OS}_${ARCH}.zip"
    URL="https://github.com/esrrhs/pingtunnel/releases/latest/download/${FILE}"

    echo "Detected: OS=$OS ARCH=$ARCH"
    echo "Downloading: $URL"

    mkdir -p /opt/pingtunnel
    cd /opt/pingtunnel

    curl -fLO "$URL" || {
        echo "Failed to download $FILE"
        exit 1
    }

    ensure_unzip
    unzip -o "$FILE" || {
        echo "Failed to unzip $FILE"
        exit 1
    }

    chmod +x pingtunnel
    rm -f "$FILE"
}

create_service() {
    echo "Creating systemd service..."

    EXEC_ARGS="-type server -nolog 1 -key ${PINGTUNNEL_KEY} -encrypt ${PINGTUNNEL_ENCRYPT} -encrypt-key ${PINGTUNNEL_ENCRYPT_KEY} -icmp_l ${PINGTUNNEL_ICMP_L}"
    if [ -n "$PINGTUNNEL_FORWARD" ]; then
        EXEC_ARGS="$EXEC_ARGS -forward ${PINGTUNNEL_FORWARD}"
    fi

    cat <<EOF >/etc/systemd/system/pingtunnel.service
[Unit]
Description=PingTunnel Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/pingtunnel
ExecStart=/opt/pingtunnel/pingtunnel ${EXEC_ARGS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable pingtunnel
    systemctl restart pingtunnel

    echo "Pingtunnel service is running."
}

show_final_info() {
    SERVER_IP=$(curl -s https://api.ipify.org)
    echo ""
    echo "Installation complete."
    echo "---------------------------"
    echo "Server IP   : $SERVER_IP"
    echo "Key         : $PINGTUNNEL_KEY"
    echo "Encrypt     : $PINGTUNNEL_ENCRYPT"
    echo "Encrypt Key : $PINGTUNNEL_ENCRYPT_KEY"
    echo "---------------------------"
}

main() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Please run this script as root (use sudo)"
        exit 1
    fi

    while true; do
        read -rp "Enter a key for PingTunnel (-key, numbers only) [default: 0]: " PINGTUNNEL_KEY
        PINGTUNNEL_KEY="${PINGTUNNEL_KEY:-0}"
        if [[ "$PINGTUNNEL_KEY" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "Please enter numbers only."
        fi
    done

    while true; do
        read -rp "Encryption mode (-encrypt) [aes128/aes256/chacha20, default: aes256]: " PINGTUNNEL_ENCRYPT
        PINGTUNNEL_ENCRYPT="${PINGTUNNEL_ENCRYPT:-aes256}"
        case "$PINGTUNNEL_ENCRYPT" in
        aes128 | aes256 | chacha20) break ;;
        *) echo "Please enter aes128, aes256, or chacha20." ;;
        esac
    done

    read -rp "Encryption key (-encrypt-key): " PINGTUNNEL_ENCRYPT_KEY

    read -rp "ICMP listen address (-icmp_l) [default: 0.0.0.0]: " PINGTUNNEL_ICMP_L
    PINGTUNNEL_ICMP_L="${PINGTUNNEL_ICMP_L:-0.0.0.0}"

    read -rp "Forward TCP through proxy (-forward, e.g. socks5://localhost:2080) [default: empty]: " PINGTUNNEL_FORWARD
    PINGTUNNEL_FORWARD="${PINGTUNNEL_FORWARD:-}"

    install_pingtunnel
    create_service
    show_final_info
}

main
