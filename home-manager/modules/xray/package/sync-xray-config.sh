#!/usr/bin/env bash
#
# sync-xray-config.sh
#
# Syncs the local Xray instance from a Remnawave subscription:
#   1. Fetches the raw Xray config from the subscription URL.
#   2. Takes the FIRST element if the response is a JSON array.
#   3. Validates the candidate config, then atomically installs it.
#   4. Updates GeoIP / Geosite data files (rootless, no installer script).
#   5. Restarts the Xray user service.
#

set -euo pipefail

# ============================================================
# 1. CONFIGURATION — EDIT THESE
# ============================================================

# Remnawave subscription URL
SUB_URL="https://sub.be-free.online/f-_CwgsXqmDH_xqs"

# User-Agent that matches your Response Rule
USER_AGENT="XrayNotebook/1.0"

# Paths.
# IMPORTANT: XRAY_CONFIG_DIR must be the SAME directory the running Xray reads
# geo files from (its XRAY_LOCATION_ASSET). Otherwise geo files get updated
# here while Xray keeps reading stale ones from the default asset dir.
XRAY_CONFIG_DIR="@workingDirectory@"
XRAY_CONFIG_FILE="@configFile@"

# Command to restart Xray
XRAY_RESTART_CMD="systemctl --user restart xray.service"

# Geo data sources
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

# ============================================================
# 2. HELPERS
# ============================================================

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# ============================================================
# 3. FETCH SUBSCRIPTION
# ============================================================

# --fail: non-zero exit on HTTP errors; --max-time: hard timeout.
BODY=$(curl -sS --fail --max-time 30 \
    -H "User-Agent: ${USER_AGENT}" \
    "${SUB_URL}") || { log "ERROR: failed to fetch subscription"; exit 1; }

if [[ -z "${BODY}" ]]; then
    log "ERROR: empty response from server"
    exit 1
fi

# ============================================================
# 4. VALIDATE & EXTRACT CONFIG
# ============================================================

# Reject anything that is not valid JSON before processing further.
if ! echo "${BODY}" | jq empty 2>/dev/null; then
    log "ERROR: response is not valid JSON"
    exit 1
fi

# If the response is an array, take the first element; otherwise keep as-is.
# Result is a single JSON object (no surrounding [ ]).
RESULT=$(echo "${BODY}" | jq 'if type == "array" then .[0] else . end')

if [[ "${RESULT}" == "null" ]]; then
    log "ERROR: config array is empty (no first element)"
    exit 1
fi

# ============================================================
# 5. INSTALL CONFIG (atomic: test a temp file, then replace)
# ============================================================

# Temp file in the same dir as the target so the final mv is an atomic rename.
# mktemp with a .json suffix so Xray detects the JSON format by extension.
CONFIG_TMP="$(mktemp "${XRAY_CONFIG_DIR}/config.XXXXXX.json")"
echo "${RESULT}" > "${CONFIG_TMP}"

# Validate the candidate config BEFORE touching the live file.
# NOTE: `xray run -test` is not documented in the official Xray-core docs;
# confirm the exact flag with `xray help run` for your build.
if ! xray run -test -config "${CONFIG_TMP}"; then
    log "ERROR: xray config test failed, not restarting"
    rm -f "${CONFIG_TMP}"
    exit 1
fi

# Passed the test — replace the live config atomically.
mv "${CONFIG_TMP}" "${XRAY_CONFIG_FILE}"
log "Saved config to ${XRAY_CONFIG_FILE}"

# ============================================================
# 6. UPDATE GEO FILES (rootless, download + verify + atomic install)
# ============================================================

log "Updating GeoIP and Geosite..."

# Temp dir inside XRAY_CONFIG_DIR so the final mv stays on the same filesystem.
tmp="$(mktemp -d "${XRAY_CONFIG_DIR}/.geodata.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

# Download a .dat file together with its .sha256sum sidecar.
# -fsSL: follow redirects, fail on HTTP errors, quiet but show errors.
fetch() {
    curl -fsSL -o "${tmp}/$2"           "$1"
    curl -fsSL -o "${tmp}/$2.sha256sum" "$1.sha256sum"
}

fetch "${GEOIP_URL}"   geoip.dat
fetch "${GEOSITE_URL}" geosite.dat

# Verify integrity before installing anything.
if ! ( cd "${tmp}" && sha256sum -c geoip.dat.sha256sum geosite.dat.sha256sum ); then
    log "ERROR: geodata checksum verification failed"
    exit 1
fi

# Atomically move verified files into place.
mv "${tmp}/geoip.dat"   "${XRAY_CONFIG_DIR}/geoip.dat"
mv "${tmp}/geosite.dat" "${XRAY_CONFIG_DIR}/geosite.dat"
log "GeoIP and Geosite updated successfully!"

# ============================================================
# 7. RESTART XRAY
# ============================================================

log "Restarting Xray..."
if eval "${XRAY_RESTART_CMD}"; then
    log "Xray successfully restarted!"
else
    log "ERROR: xray restart failed"
    exit 1
fi