#!/usr/bin/env bash

# Строгий режим для bash
set -euo pipefail
IFS=$'\n\t'

if [ "$(id -u)" -eq 0 ]; then
    print --error "This script should not be run as root"
    exit 1
fi
