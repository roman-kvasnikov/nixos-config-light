{pkgs, ...}: {
  # Add to hyprland.conf
  # bindl=,monitoraddedv2,exec,hyprland-display-switcher
  # bindl=,monitorremovedv2,exec,hyprland-display-switcher

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "hyprland-display-switcher" ''
      #!/usr/bin/env bash
      set -euo pipefail

      sleep 0.5

      MONITORS=$(hyprctl monitors all -j)

      INTERNAL=$(echo "$MONITORS" | ${pkgs.jq}/bin/jq -r '.[] | select(.name | test("^eDP")) | .name')
      EXTERNAL=$(echo "$MONITORS" | ${pkgs.jq}/bin/jq -r '.[] | select(.name | test("^eDP") | not) | .name')

      if [ -n "$EXTERNAL" ]; then
          PRIMARY=$(echo "$EXTERNAL" | head -n1)

          hyprctl keyword monitor "$PRIMARY,preferred,auto,1"
          hyprctl keyword monitor "$INTERNAL,disable"
      else
          hyprctl keyword monitor "$INTERNAL,preferred,auto,1.6"
      fi
    '')
  ];
}
