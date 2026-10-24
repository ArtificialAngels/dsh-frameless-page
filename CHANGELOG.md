# Changelog

## 0.1.29
- Handle upstream 0.9.5 window-state: hide the capsule when the shell reports `nativeChromeForced` or `frameless:false` (native title bar restored), so there is never a double title bar.
- Bundle the optional patched 0.9.5 shell (`native/`) with the rejected cosmetic tweaks: 6px resize grip, no DWM white hairline, iOS traffic lights. Capsule works on the stock shell already.
## 0.1.28
- Removed the "switch to old UI" button and all plugin-side old-UI/uiMode handling; the plugin now always renders the island only (upstream rejected the shell-side PR, so it ships standalone).
## 0.1.27
- Dot colors changed to fixed red (#ff5f57) / yellow (#ffd60a) / blue (#0a84ff).
## 0.1.26
- Reverted the color cycling; the three lamps are fixed again, now yellow (#ffd60a) / green (#34c759) / blue (#0a84ff).
## 0.1.25
- The three dots no longer use fixed colors: each lamp cycles red → green → blue every 6s (phase-shifted by 2s), so at any moment the three dots show three different, alternating colors; glow follows the current color.
## 0.1.24
- Keep the three pill dots exactly aligned: removed the staggered `scale()` from the busy blink animation (now opacity/saturation only) and hard-blockified the dots (`display:block; margin:0; align-self:center`) so fractional DPI/zoom cannot shift their tops.
## 0.1.23
- Initial standalone release of the island pill UI.
- Idle: three dots only; hover: outline only; click to expand; 1.2s leave collapse.
- Expanded row: File / Switch to old UI / View / Help / Minimize / Maximize / Close.
- Drag anywhere non-button (>3px), top-5% drag zone, double-click maximize/restore.
- Fullscreen keeps the pill visible and clickable to exit.
- New/old UI switch with persistence; iOS-style traffic lights in the native bar.
- Removed the legacy "gravity page" floating overlay.






