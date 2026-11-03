#!/usr/bin/env bash
# helium-startpage Linux uninstaller - reverts install.sh.
set -euo pipefail

page_dir="$HOME/.local/share/helium-start"
user_apps="$HOME/.local/share/applications"

# 1. strip the flag from patched user launchers (never from system ones)
shopt -s nullglob
count=0
for f in "$user_apps"/*.desktop; do
    if grep -qi helium "$f" 2>/dev/null && grep -q 'custom-ntp=' "$f"; then
        sed -i 's| *--custom-ntp="[^"]*"||g' "$f"
        count=$((count + 1))
    fi
done
[ "$count" -gt 0 ] && echo "[ok] removed the flag from $count launcher(s)" || echo "[ok] no patched launchers found"

# 2. remove the installed page (the repo copy next to this script stays)
rm -rf "$page_dir"
echo "[removed] $page_dir"

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$user_apps" 2>/dev/null || true
