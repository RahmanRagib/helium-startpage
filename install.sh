#!/usr/bin/env bash
# helium-startpage Linux installer.
# Copies the startpage to ~/.local/share/helium-start and appends
# --custom-ntp to every Helium .desktop launcher found, so new tabs
# open the startpage. Idempotent: safe to rerun. No root needed -
# system-wide launchers are overridden with a patched user copy.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
page_dir="$HOME/.local/share/helium-start"
user_apps="$HOME/.local/share/applications"

if [ ! -d "$here/startpage" ]; then
    echo "error: startpage/ folder not found next to this script: $here" >&2
    exit 1
fi

# percent-encode spaces only; the rest of a $HOME path is URL-safe
url="file://$(printf '%s' "$page_dir" | sed 's/ /%20/g')/index.html"
flag="--custom-ntp=\"$url\""

# 1. install the page
mkdir -p "$page_dir"
cp -r "$here/startpage/." "$page_dir/"
echo "[ok] startpage copied to $page_dir"

# 2. find every Helium .desktop launcher (user copies win over system ones)
shopt -s nullglob
user_files=()
mkdir -p "$user_apps"
for f in "$user_apps"/*.desktop /usr/share/applications/*.desktop /usr/local/share/applications/*.desktop; do
    if grep -qi helium "$f" 2>/dev/null; then
        dest="$f"
        case "$f" in
            "$user_apps"/*) ;;
            *)  # system launcher: create a user copy so we never need root
                dest="$user_apps/$(basename "$f")"
                if [ ! -f "$dest" ]; then
                    cp "$f" "$dest"
                fi
                ;;
        esac
        user_files+=("$dest")
    fi
done

# dedupe in case a system launcher was already overridden by a user copy
if [ "${#user_files[@]}" -gt 1 ]; then
    mapfile -t user_files < <(printf '%s\n' "${user_files[@]}" | sort -u)
fi

if [ "${#user_files[@]}" -eq 0 ]; then
    echo "error: no Helium .desktop launcher found - install Helium, launch it once, then rerun" >&2
    exit 1
fi

# 3. patch each Exec line: drop any previous --custom-ntp, then insert the
#    flag before the first % field code (or at the end if there is none)
for f in "${user_files[@]}"; do
    awk -v flag="$flag" '
        /^Exec=/ {
            gsub(/ *--custom-ntp="[^"]*"/, "")
            if ($0 ~ /%/) sub(/%/, flag " %")
            else if ($0 != "Exec=") $0 = $0 " " flag
            else { print "warning: empty Exec line in page launcher, skipping" > "/dev/stderr"; next }
        }
        { print }
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
echo "[ok] ${#user_files[@]} launcher(s) patched with the custom-ntp flag"

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$user_apps" 2>/dev/null || true

echo
echo "done. Quit and relaunch Helium - it will open this startpage natively as its new tab."
