#!/usr/bin/env bash

set -euo pipefail

readonly CONFIG="@configPath@"
readonly IFACE="@interfaceName@"

usage() {
    cat <<EOF
Usage: homevpn <command>

Commands:
connect      Bring up the VPN tunnel
disconnect   Tear down the VPN tunnel
status       Show tunnel status
toggle       Toggle tunnel state

Config: $CONFIG
EOF
    exit 1
}

is_up() {
    ip link show "$IFACE" &>/dev/null
}

cmd_connect() {
    if is_up; then
        echo "homevpn: already connected"
        cmd_status
        return 0
    fi
    if [[ ! -r "$CONFIG" ]]; then
        echo "homevpn: config not found or not readable: $CONFIG" >&2
        exit 2
    fi
    echo "homevpn: connecting..."
    sudo awg-quick up "$CONFIG"
    echo "homevpn: connected"
}

cmd_disconnect() {
    if ! is_up; then
        echo "homevpn: already disconnected"
        return 0
    fi
    echo "homevpn: disconnecting..."
    sudo awg-quick down "$CONFIG"
    echo "homevpn: disconnected"
}

cmd_status() {
    if ! is_up; then
        echo "homevpn: disconnected"
        return 0
    fi
    echo "homevpn: connected"
    sudo awg show "$IFACE"
}

cmd_toggle() {
    if is_up; then
        cmd_disconnect
    else
        cmd_connect
    fi
}

case "${1:-}" in
    connect|up)        cmd_connect ;;
    disconnect|down)   cmd_disconnect ;;
    status|show)       cmd_status ;;
    toggle)            cmd_toggle ;;
    -h|--help|help|"") usage ;;
    *)                 echo "homevpn: unknown command: $1" >&2; usage ;;
esac