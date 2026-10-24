# Changelog

## 0.1.37
- Remove the transparent overlay strips used for window resizing (they could intermittently render as an opaque 3px band over the wallpaper). Edge/corner resizing is now hit-tested from document pointer coordinates, with cursor hints set via JS; nothing is drawn over the page.
## 0.1.36
- Full-bleed window: the shell can now use a 0px inset (no black border). The plugin adds transparent edge resize strips (left/right/top/bottom + corners) that send `dsh-portable/window-resize {edge}` so the native window still resizes from all four sides.
## 0.1.35
- Do not auto-hide the capsule on the transient `frameless:false` / `nativeChromeForced` window-state that the 0.9.5 shell posts during startup; it could leave the capsule permanently hidden. The capsule is always shown and the shell owns native-bar visibility.
## 0.1.34
- Refresh the shipped icon to the island pill artwork (0.1.33 packed the old gravity icon).
## 0.1.33
- Align the manifest with the DSH bundle spec: `dsh.manifestVersion: 1`, `engines.dsh`, top-level `icon`, `dsh.compatibility.profiles`, exported `./icon` / `./locale/*.json`, `CHANGELOG.md` + `LICENSE` in `files`.
- Replace the stale gravity-page locale files with the island strings and `meta.title` / `meta.description` used by Plugin Manager.
- Enable `dsh.client.immediately` so the overlay loads at boot; drop the unused `ui-layout` client injection.
- Remove the broken `test` script (no smoke suite ships) and refresh keywords/description.

## 0.1.32
- Fix collapse order/width: fall back to the ••• tier only when the three top-level menus do not fit; fold Help -> View -> File as width shrinks. Expanded width equals measured content (150px floor removed).

## 0.1.31
- Flatten menu commands into the row when width allows; fold groups back one by one when space is tight.

## 0.1.30
- New-UI only: removed the patched-shell bundle; runs on the stock DSH-Portable 0.9.5+ window-chrome bridge.

## 0.1.29
- Hide the capsule when the shell reports `nativeChromeForced` / `frameless:false`.

## 0.1.28
- Removed the old-UI switch and all `uiMode` handling from the plugin.

## 0.1.27
- Fixed dot palette: red / yellow / blue.

## 0.1.26
- Reverted color cycling; fixed yellow / green / blue dots.

## 0.1.25
- Dots cycle red -> green -> blue (reverted in 0.1.26).

## 0.1.24
- Keep the three dots on one line (no scale in the busy blink; block-level, centered dots).

## 0.1.23
- Top 5% double-click maximizes/restores.

## 0.1.22
- Top drag zone narrowed from 10% to 5%.

## 0.1.21
- Top 10% non-control area drags the window.

## 0.1.20
- Centered the dots inside the border; capsule +1 dot diameter long.

## 0.1.19
- Collapse dots only after the shrink animation; collapsed length 1.5x dots, thinner capsule, moved up one dot diameter.

## 0.1.18
- Hover shows only the outline; expansion requires a click; drag starts after >3px.

## 0.1.17
- Fullscreen keeps the pill visible (click to exit); pointer-capture drag.

## 0.1.16
- Removed the legacy gravity page (Ctrl+Alt+G, sidebar entry, overlay, core.js).

## 0.1.15
- Collapsed pill becomes a perfect circle (zero straight edge).

## 0.1.14
- Reverted the ellipse, zero side padding, no reserved space, click (on release) expands.




