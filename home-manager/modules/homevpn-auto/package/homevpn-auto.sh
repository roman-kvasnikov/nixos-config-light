#!/usr/bin/env bash

set -euo pipefail

# Configuration injected at build time
readonly HOME_SSID="@homeSsid@"
readonly HOME_GATEWAY_IP="@homeGatewayIp@"
readonly HOME_GATEWAY_MAC="@homeGatewayMac@"
readonly OVERRIDE_TIMEOUT_SECONDS="@overrideTimeoutSeconds@"
readonly HANDSHAKE_MAX_AGE_SECONDS="@handshakeMaxAgeSeconds@"
readonly IFACE="@interfaceName@"
readonly OVERRIDE_FILE="@overrideFile@"

# Logger tag for journalctl filtering
log() {
    logger -t homevpn-auto -- "$*"
    echo "homevpn-auto: $*"
}

# Detect home network: SSID + gateway IP + gateway MAC must all match
is_at_home() {
    local current_ssid current_gw current_mac

    current_ssid="$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 || true)"
    current_gw="$(ip route show default 2>/dev/null | awk '/default/ {print $3; exit}' || true)"

    if [[ -z "$current_gw" ]]; then
        log "no default gateway, considering not-at-home"
        return 1
    fi

    current_mac="$(ip neigh show "$current_gw" 2>/dev/null | awk '{print $5}' | head -1 || true)"

    if [[ "$current_ssid" != "$HOME_SSID" ]]; then
        log "ssid mismatch: '$current_ssid' != '$HOME_SSID'"
        return 1
    fi
    if [[ "$current_gw" != "$HOME_GATEWAY_IP" ]]; then
        log "gateway IP mismatch: '$current_gw' != '$HOME_GATEWAY_IP'"
        return 1
    fi
    if [[ "$current_mac" != "$HOME_GATEWAY_MAC" ]]; then
        log "gateway MAC mismatch: '$current_mac' != '$HOME_GATEWAY_MAC'"
        return 1
    fi

    return 0
}

# Check if user manually changed VPN state recently
manual_override_active() {
    [[ ! -f "$OVERRIDE_FILE" ]] && return 1

    local override_ts now age
    override_ts="$(stat -c %Y "$OVERRIDE_FILE")"
    now="$(date +%s)"
    age=$((now - override_ts))

    if [[ "$age" -lt "$OVERRIDE_TIMEOUT_SECONDS" ]]; then
        local remaining=$((OVERRIDE_TIMEOUT_SECONDS - age))
        log "manual override active, ${remaining}s remaining"
        return 0
    fi

    return 1
}

is_vpn_up() {
    ip link show "$IFACE" &>/dev/null
}

# Returns 0 if handshake is fresh, 1 if stale or absent
handshake_is_fresh() {
    local handshake_ts now age
    handshake_ts="$(sudo awg show "$IFACE" latest-handshakes 2>/dev/null | awk '{print $2}' | head -1 || echo 0)"

    if [[ -z "$handshake_ts" || "$handshake_ts" -eq 0 ]]; then
        return 1
    fi

    now="$(date +%s)"
    age=$((now - handshake_ts))

    if [[ "$age" -gt "$HANDSHAKE_MAX_AGE_SECONDS" ]]; then
        log "handshake stale: ${age}s old"
        return 1
    fi

    return 0
}

main() {
    if manual_override_active; then
        log "skipping: manual override"
        exit 0
    fi

    if is_at_home; then
        if is_vpn_up; then
            log "at home with VPN up, disconnecting"
            homevpn --auto disconnect
        else
            log "at home, VPN already down, nothing to do"
        fi
    else
        if ! is_vpn_up; then
            log "away from home, VPN down, connecting"
            homevpn --auto connect
        elif ! handshake_is_fresh; then
            log "away from home, VPN up but handshake stale, reconnecting"
            homevpn --auto disconnect
            sleep 1
            homevpn --auto connect
        else
            log "away from home, VPN up with fresh handshake, nothing to do"
        fi
    fi
}

main "$@"