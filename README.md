# helium-startpage

A minimalist new-tab page for the [Helium](https://github.com/imputnet/helium)
browser, using Helium's built-in `--custom-ntp` flag — no extension needed.

The page shows a 3D animated ASCII art logo and a search bar with `!bang`
shortcuts. **Nothing else is enabled by default** — clock, date, separator and
the links row are all off. Turn on what you want via the in-page settings panel
(gear icon); each browser profile remembers its own choices. The links list
starts empty on every profile - you add links manually, and "reset links"
clears it back to empty.

Works for normal windows *and* incognito (both load the same baked page; your
customizations live per-profile, and incognito starts fresh each session).

## Install - Windows

1. Clone or download this folder anywhere.
2. Double-click `run-setup.cmd` (or run `powershell -ExecutionPolicy Bypass -File setup.ps1`).
3. Fully quit and relaunch Helium.

What it does: copies `startpage/` to `%LOCALAPPDATA%\Helium-Start` and appends
`--custom-ntp="file:///.../index.html"` to every Helium shortcut it finds
(Start Menu, Desktop, taskbar). Idempotent - rerunning never duplicates the
flag. `run-uninstall.cmd` reverts everything.

Tip: for immunity on any launch path (e.g. bare exe), also set it once in
`chrome://flags` → search "Custom New Tab Page" → the same
`file:///C:/Users/<you>/AppData/Local/Helium-Start/index.html` URL → Relaunch.

## Install - Linux

1. Clone or download this folder anywhere.
2. `./install.sh`
3. Fully quit and relaunch Helium.

What it does: copies `startpage/` to `~/.local/share/helium-start` and appends
`--custom-ntp="file:///.../index.html"` to every Helium `.desktop` launcher it
finds. System-wide launchers are overridden by a patched copy in
`~/.local/share/applications`, so no root is needed. Idempotent.
`./uninstall.sh` reverts everything (system launchers recover their stock
behavior automatically).

## Notes

- The new tab page is a plain local web page (`file://`), loaded by Helium's
  native custom-NTP feature (upstream patch origin:
  [ungoogled-chromium custom-ntp flag](https://github.com/ungoogled-chromium/ungoogled-chromium)).
- Customizations persist in the browser's localStorage per profile. Incognito
  has no persistent storage by design - it always starts with the defaults
  (art + search only) and keeps changes you make during the session.
- The startpage is a modified version of
  [Simple-start](https://github.com/SpringDallies/Simple-start) by SpringDallies
  with layout defaults, timing fixes and packaging by this repo.
- MIT licensed (see `LICENSE`). The upstream Simple-start page files have no
  own license text - treat this repo's license as covering the packaging and
  modifications, and consult the upstream project about the base page.

## Folder layout

```
startpage/            the page itself (source of truth - edit here, rerun setup)
setup.ps1             Windows installer logic
run-setup.cmd         double-click entry for Windows
uninstall.ps1         Windows uninstaller
install.sh            Linux installer
uninstall.sh          Linux uninstaller
```
