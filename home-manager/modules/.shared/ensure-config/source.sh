#!/usr/bin/env bash

# Строгий режим для bash
set -euo pipefail
IFS=$'\n\t'

if [ $# -ne 2 ]; then
    print --error "Usage: $0 <config_dir> <config_file>"
    print --info "Example: $0 /home/user/.config/package /home/user/.config/package/config.json"
    exit 1
fi

mkdir -p "$1"

if [ ! -f "$2" ]; then
    local example_file="$1/config.example.json"

    if [ ! -f "$example_file" ]; then
        print --error "Example config file not found: $example_file"
        exit 1
    fi

    print --info "Creating default config from example..."
    cp "$example_file" "$2"
    print --success "Config created at: $2"
fi
