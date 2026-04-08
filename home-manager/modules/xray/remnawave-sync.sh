#!/usr/bin/env bash
#
# remnawave-sync.sh
#
# Fetches Xray JSON configs from a Remnawave subscription,
# picks the one matching NODE_FILTER, and writes it to config.json.
#
# Remnawave returns an array of configs (one per node).
# This script selects the right one by matching the outbound
# server address against NODE_FILTER.
#
# Cron example (daily at 05:00):
#   0 5 * * * /usr/local/bin/remnawave-sync.sh >> /var/log/remnawave-sync.log 2>&1
#

set -euo pipefail

# ============================================================
# CONFIGURATION - EDIT THESE
# ============================================================

# Remnawave subscription URL
SUB_URL="https://rw-subscription.kvasok.xyz/LtK5tt9LfzVfHLPC"

# User-Agent that matches your Response Rule for the Default template
USER_AGENT="NotebookXray/1.0"

# Node address to select from the subscription array
# Must match the address in the outbound's vnext[].address
NODE_FILTER="ee.be-free.online"

# Path to the Xray config file
XRAY_CONFIG="${HOME}/.config/xray/config.json"

# Command to restart Xray
XRAY_RESTART_CMD="systemctl --user restart xray.service"

# ============================================================

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

log "=== Starting sync ==="

# --- 1. Fetch config from subscription ---

BODY=$(curl -sS --fail --max-time 30 \
    -H "User-Agent: ${USER_AGENT}" \
    "${SUB_URL}") || { log "ERROR: failed to fetch subscription"; exit 1; }

if [[ -z "${BODY}" ]]; then
    log "ERROR: empty response from server"
    exit 1
fi

# --- 2. Validate JSON ---

TMPFILE=$(mktemp "${XRAY_CONFIG}.tmp.XXXXXX")
trap 'rm -f "${TMPFILE}"' EXIT

if ! echo "${BODY}" | jq '.' > "${TMPFILE}" 2>/dev/null; then
    log "ERROR: response is not valid JSON"
    log "First 200 chars: $(echo "${BODY}" | head -c 200)"
    exit 1
fi

# --- 3. Extract the right node config ---

JSON_TYPE=$(jq 'type' "${TMPFILE}" -r)

if [[ "${JSON_TYPE}" == "array" ]]; then
    TOTAL=$(jq 'length' "${TMPFILE}")
    log "Received array of ${TOTAL} node configs"

    # Find the element where any outbound has vnext[].address matching NODE_FILTER
    jq --arg node "${NODE_FILTER}" \
        '[ .[] | select(.outbounds[]?.settings?.vnext?[]?.address? == $node) ] | .[0]' \
        "${TMPFILE}" > "${TMPFILE}.filtered"

    # Check if we found a match
    if [[ $(jq 'type' "${TMPFILE}.filtered" -r 2>/dev/null) != "object" ]] \
       || [[ $(jq '. == null' "${TMPFILE}.filtered" -r 2>/dev/null) == "true" ]]; then
        log "ERROR: no config found matching node '${NODE_FILTER}'"
        log "Available nodes:"
        jq -r '[ .[] | .outbounds[]?.settings?.vnext?[]?.address? ] | unique | .[] // empty' "${TMPFILE}" \
            | while read -r addr; do log "  - ${addr}"; done
        exit 1
    fi

    mv "${TMPFILE}.filtered" "${TMPFILE}"
    log "Selected node: ${NODE_FILTER}"

elif [[ "${JSON_TYPE}" == "object" ]]; then
    log "Received a single config object"
else
    log "ERROR: unexpected JSON type: ${JSON_TYPE}"
    exit 1
fi

# --- 4. Validate selected config ---

if [[ $(jq 'has("outbounds")' "${TMPFILE}") != "true" ]]; then
    log "ERROR: config is missing 'outbounds' section"
    exit 1
fi

OB_COUNT=$(jq '.outbounds | length' "${TMPFILE}")
log "Config has ${OB_COUNT} outbounds"

# --- 5. Compare with current config ---

if [[ -f "${XRAY_CONFIG}" ]]; then
    OLD_HASH=$(jq -cS '.' "${XRAY_CONFIG}" 2>/dev/null | md5sum | cut -d' ' -f1)
    NEW_HASH=$(jq -cS '.' "${TMPFILE}" | md5sum | cut -d' ' -f1)

    if [[ "${OLD_HASH}" == "${NEW_HASH}" ]]; then
        log "Config unchanged, skipping"
        exit 0
    fi
    log "Changes detected"
fi

# --- 6. Atomic replace + restart ---

if [[ -f "${XRAY_CONFIG}" ]]; then
    cp "${XRAY_CONFIG}" "${XRAY_CONFIG}.bak"
fi

trap - EXIT
mv "${TMPFILE}" "${XRAY_CONFIG}"
log "Config written: ${XRAY_CONFIG}"

log "Restarting Xray..."
if eval "${XRAY_RESTART_CMD}"; then
    log "=== Done: ${NODE_FILTER} (${OB_COUNT} outbounds) ==="
else
    log "ERROR: restart failed, rolling back"
    [[ -f "${XRAY_CONFIG}.bak" ]] && mv "${XRAY_CONFIG}.bak" "${XRAY_CONFIG}"
    eval "${XRAY_RESTART_CMD}" || true
    exit 1
fi