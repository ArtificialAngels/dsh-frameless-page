# Changelog

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

