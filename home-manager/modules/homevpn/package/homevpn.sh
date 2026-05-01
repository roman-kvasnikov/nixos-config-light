#!/usr/bin/env bash

set -euo pipefail

readonly CONFIG_FILE="@configFile@"
readonly IFACE="@interfaceName@"
readonly OVERRIDE_FILE="@overrideFile@"

# Internal flag: --auto means called by automation, don't touch override
AUTO_MODE=0
if [[ "${1:-}" == "--auto" ]]; then
    AUTO_MODE=1
    shift
fi

usage() {
    cat <<EOF
Usage: homevpn <command>

Commands:
connect      Bring up the VPN tunnel
disconnect   Tear down the VPN tunnel
status       Show tunnel status
toggle       Toggle tunnel state

Config: $CONFIG_FILE
EOF
    exit 1
}

is_up() {
    ip link show "$IFACE" &>/dev/null
}

mark_manual() {
    # Skip when called by automation
    [[ "$AUTO_MODE" -eq 1 ]] && return 0
    mkdir -p "$(dirname "$OVERRIDE_FILE")"
    touch "$OVERRIDE_FILE"
}

cmd_connect() {
    if is_up; then
        echo "homevpn: already connected"
        cmd_status
        mark_manual
        return 0
    fi
    if [[ ! -r "$CONFIG_FILE" ]]; then
        echo "homevpn: config not found or not readable: $CONFIG_FILE" >&2
        exit 2
    fi
    echo "homevpn: connecting..."
    sudo awg-quick up "$CONFIG_FILE"
    mark_manual
    echo "homevpn: connected"
}

cmd_disconnect() {
    if ! is_up; then
        echo "homevpn: already disconnected"
        mark_manual
        return 0
    fi
    echo "homevpn: disconnecting..."
    sudo awg-quick down "$CONFIG_FILE"
    mark_manual
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