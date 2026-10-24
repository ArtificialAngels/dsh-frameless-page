# Optional patched shell (v0.9.5)

DSH-Portable 0.9.5 already ships the window-chrome bridge (`windowChrome` /
`windowDrag` / `windowControls` / `windowState` / `windowCommand` / `windowMenu`),
so the capsule plugin works on the stock shell.

This folder bundles a locally patched `DeepSeek-Herness.exe` (built from upstream
v0.9.5 + the cosmetic tweaks that were not merged upstream):

- 6px window resize grip (upstream: 4px)
- DWM border line removed (`DWMWA_COLOR_NONE`) so no white hairline on light system themes
- iOS-style traffic lights in the native title strip (only visible when the native bar is shown)

Install (DSH-Portable must be closed):

```powershell
powershell -ExecutionPolicy Bypass -File .\install-pill-shell.ps1
```

The script backs up the current exe to `DeepSeek-Herness.exe.stock-backup`.
Product updates replace the exe; re-run this script after each update.
