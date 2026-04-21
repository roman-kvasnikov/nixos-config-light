#!/usr/bin/env bash
#
# remnawave-sync.sh
#
# Fetches Xray JSON configs from a Remnawave subscription,
# selects the config containing an outbound matching NODE_ADDRESS:NODE_PORT,
# then strips balancer, observatory, and all unrelated proxy outbounds —
# leaving a clean single-node config ready for direct use.
#
# Remnawave returns an array of configs (one per node).
# This script selects the right one, then:
#   1. Keeps only the outbound matching NODE_ADDRESS:NODE_PORT
#      plus all "infrastructure" outbounds (freedom, blackhole, dns, loopback)
#   2. Removes observatory / burstObservatory from the root
#   3. Removes balancers[] from routing
#   4. Rewrites routing rules: balancerTag → outboundTag of the matched outbound
#
# Cron example (daily at 05:00):
#   0 5 * * * /usr/local/bin/remnawave-sync.sh >> /var/log/remnawave-sync.log 2>&1
#

set -euo pipefail

# ============================================================
# CONFIGURATION — EDIT THESE
# ============================================================

# Remnawave subscription URL
SUB_URL="https://sub.be-free.online/LtK5tt9LfzVfHLPC"

# User-Agent that matches your Response Rule for the Default template
USER_AGENT="NotebookXray/1.0"

# Exact outbound to keep: address + port
NODE_ADDRESS="ee.be-free.online"
NODE_PORT=443

# Paths
XRAY_CONFIG_DIR="@workingDirectory@"
XRAY_CONFIG_FILE="@configFile@"

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

TMPFILE=$(mktemp "${XRAY_CONFIG_FILE}.tmp.XXXXXX")
trap 'rm -f "${TMPFILE}" "${TMPFILE}.filtered" "${TMPFILE}.cleaned" "${TMPFILE}.normalized" 2>/dev/null' EXIT

if ! echo "${BODY}" | jq '.' > "${TMPFILE}" 2>/dev/null; then
    log "ERROR: response is not valid JSON"
    log "First 200 chars: $(echo "${BODY}" | head -c 200)"
    exit 1
fi

# --- 3. Select the config containing our node ---

JSON_TYPE=$(jq -r 'type' "${TMPFILE}")

if [[ "${JSON_TYPE}" == "array" ]]; then
    TOTAL=$(jq 'length' "${TMPFILE}")
    log "Received array of ${TOTAL} node configs"

    # Find the first element where any outbound has vnext[].address AND vnext[].port matching
    # Using any() to avoid duplicating elements when multiple vnext entries match
    jq --arg addr "${NODE_ADDRESS}" --argjson port "${NODE_PORT}" \
        'first(.[] | select(any(
            .outbounds[]?.settings?.vnext?[]?;
            .address? == $addr and .port? == $port
        )))' \
        "${TMPFILE}" > "${TMPFILE}.filtered"

    if [[ $(jq -r 'type' "${TMPFILE}.filtered" 2>/dev/null) != "object" ]] \
       || [[ $(jq -r '. == null' "${TMPFILE}.filtered" 2>/dev/null) == "true" ]]; then
        log "ERROR: no config found matching ${NODE_ADDRESS}:${NODE_PORT}"
        log "Available nodes:"
        jq -r '[
            .[] | .outbounds[]? | .settings?.vnext?[]? |
            select(.address? != null) |
            "\(.address):\(.port)"
        ] | unique | .[]' "${TMPFILE}" \
            | while read -r node; do log "  - ${node}"; done
        exit 1
    fi

    mv "${TMPFILE}.filtered" "${TMPFILE}"
    log "Selected config containing ${NODE_ADDRESS}:${NODE_PORT}"

elif [[ "${JSON_TYPE}" == "object" ]]; then
    log "Received a single config object"
else
    log "ERROR: unexpected JSON type: ${JSON_TYPE}"
    exit 1
fi

# --- 4. Clean the config: strip balancer, observatory, extra outbounds ---

# Determine the tag of our target outbound
TARGET_TAG=$(jq -r --arg addr "${NODE_ADDRESS}" --argjson port "${NODE_PORT}" '
    first(.outbounds[] | select(any(
        .settings?.vnext?[]?;
        .address? == $addr and .port? == $port
    ))) | .tag
' "${TMPFILE}")

if [[ -z "${TARGET_TAG}" || "${TARGET_TAG}" == "null" ]]; then
    log "ERROR: could not determine outbound tag for ${NODE_ADDRESS}:${NODE_PORT}"
    exit 1
fi
log "Target outbound tag: ${TARGET_TAG}"

# Infrastructure outbound protocols that must be preserved
# (freedom, blackhole, dns, loopback — these are not proxy outbounds)
INFRA_PROTOCOLS='["freedom", "blackhole", "dns", "loopback"]'

jq --arg tag "${TARGET_TAG}" --argjson infra "${INFRA_PROTOCOLS}" '
    # 1. Filter outbounds: keep our target + all infrastructure protocols
    .outbounds = [
        .outbounds[] |
        select(
            .tag == $tag or
            (.protocol as $p | $infra | index($p) != null)
        )
    ]

    # 2. Rename target outbound tag to "proxy"
    | .outbounds = [
        .outbounds[] |
        if .tag == $tag then .tag = "proxy" else . end
    ]

    # 3. Remove observatory and burstObservatory from root
    | del(.observatory)
    | del(.burstObservatory)

    # 4. Clean up routing
    | if .routing then
        .routing |= (
            # Remove balancers array
            del(.balancers)

            # Rewrite rules: balancerTag → outboundTag "proxy",
            # and rename any outboundTag that referenced the old tag
            | if .rules then
                .rules = [
                    .rules[] |
                    if .balancerTag then
                        del(.balancerTag) | .outboundTag = "proxy"
                    elif .outboundTag == $tag then
                        .outboundTag = "proxy"
                    else
                        .
                    end
                ]
              else . end
        )
      else . end
' "${TMPFILE}" > "${TMPFILE}.cleaned"

mv "${TMPFILE}.cleaned" "${TMPFILE}"

# --- 5. Validate cleaned config ---

if [[ $(jq 'has("outbounds")' "${TMPFILE}") != "true" ]]; then
    log "ERROR: cleaned config is missing 'outbounds' section"
    exit 1
fi

OB_COUNT=$(jq '.outbounds | length' "${TMPFILE}")
OB_TAGS=$(jq -r '[.outbounds[].tag] | join(", ")' "${TMPFILE}")
log "Cleaned config has ${OB_COUNT} outbounds: ${OB_TAGS}"

# Sanity check: "proxy" outbound must be present
if [[ $(jq '[.outbounds[].tag] | index("proxy") != null' "${TMPFILE}") != "true" ]]; then
    log "ERROR: 'proxy' outbound missing after cleanup!"
    exit 1
fi

# --- 6. Update GeoIP and Geosite ---

log "Updating GeoIP and Geosite..."

if curl -fL -o "$XRAY_CONFIG_DIR/geoip.dat.new" \
     https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat && \
   curl -fL -o "$XRAY_CONFIG_DIR/geosite.dat.new" \
     https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat; then

  # All files downloaded — make atomic replacement
  mv "$XRAY_CONFIG_DIR/geoip.dat.new" "$XRAY_CONFIG_DIR/geoip.dat"
  mv "$XRAY_CONFIG_DIR/geosite.dat.new" "$XRAY_CONFIG_DIR/geosite.dat"

  log "GeoIP and Geosite updated successfully"
else
  # Something went wrong — clean temporary files
  rm -f "$XRAY_CONFIG_DIR"/*.new
  log "ERROR: failed to update GeoIP and Geosite"
  exit 1
fi

# --- 7. Compare with current config ---

# Write pretty-printed config for install (preserve original key order)
jq '.' "${TMPFILE}" > "${TMPFILE}.normalized"

if [[ -f "${XRAY_CONFIG_FILE}" ]]; then
    # Compare ignoring shortId (Remnawave randomizes it on every subscription fetch)
    OLD_HASH=$(jq -cS 'walk(if type == "object" then del(.shortId) else . end)' "${XRAY_CONFIG_FILE}" 2>/dev/null | md5sum | cut -d' ' -f1)
    NEW_HASH=$(jq -cS 'walk(if type == "object" then del(.shortId) else . end)' "${TMPFILE}.normalized" | md5sum | cut -d' ' -f1)

    if [[ "${OLD_HASH}" == "${NEW_HASH}" ]]; then
        log "Config unchanged (shortId rotation ignored), skipping"
        exit 0
    fi
    log "Changes detected (old=${OLD_HASH} new=${NEW_HASH})"
    log "--- DIFF START ---"
    diff <(jq -S '.' "${XRAY_CONFIG_FILE}") <(jq -S '.' "${TMPFILE}.normalized") || true
    log "--- DIFF END ---"
fi

# --- 8. Atomic replace + restart ---

if [[ -f "${XRAY_CONFIG_FILE}" ]]; then
    cp "${XRAY_CONFIG_FILE}" "${XRAY_CONFIG_FILE}.bak"
fi

trap - EXIT
mv "${TMPFILE}.normalized" "${XRAY_CONFIG_FILE}"
rm -f "${TMPFILE}" "${TMPFILE}.filtered" "${TMPFILE}.cleaned" 2>/dev/null
log "Config written: ${XRAY_CONFIG_FILE}"

log "Restarting Xray..."
if eval "${XRAY_RESTART_CMD}"; then
    log "=== Done: proxy (${NODE_ADDRESS}:${NODE_PORT}, was ${TARGET_TAG}) — ${OB_COUNT} outbounds ==="
else
    log "ERROR: restart failed, rolling back"
    [[ -f "${XRAY_CONFIG_FILE}.bak" ]] && mv "${XRAY_CONFIG_FILE}.bak" "${XRAY_CONFIG_FILE}"
    eval "${XRAY_RESTART_CMD}" || true
    exit 1
fi