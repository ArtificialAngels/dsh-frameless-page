# dsh-frameless-page

A DSH client plugin that adds a Dynamic-Island style pill to **DSH-Portable**:
the native title bar leaves the layout, the page fills the window, and the pill
handles window drag / minimize / maximize / close / fullscreen through the
shell's native implementation.

![expanded](shots/island2-b2-expanded.png)

## Features

- Idle: only three dots (surface transparent).
- Hover: outline only, no expansion.
- Click (press → release, <3px): expand; click background again to collapse.
- Drag: hold anywhere that is not a button and move >3px to drag the window.
- Expanded row: File / Switch to old UI / View / Help / Minimize / Maximize / Close
  (menu commands are executed by the shell).
- Fullscreen: pill stays visible; click it or press Esc to leave fullscreen.
- Top 5% of the page: press-drag to move the window, double-click to maximize/restore.
- Styling inherits the main composer card; the three dots blink while a session runs.
- New/old UI switch persists across restarts (native title bar has iOS traffic lights).

## Requirements

The shell must expose `windowChrome` / `windowDrag` / `windowControls` /
`windowState` (`window.__DSH_PORTABLE_NATIVE__`, `windowChrome:true`).
The stock `DeepSeek-Herness.exe` does not, and the plugin is a no-op there.
The shell-side changes are in DSH-Portable PR
<https://github.com/WSL043/DSH-Portable/pull/181>.

## Install (standard DSH plugin command)

`dsh plugin` forwards its arguments to pnpm inside the profile directory, so all
pnpm specifiers work. Restart DSH after installing.

```powershell
# A. from GitHub (recommended)
E:\DSH-Portable\dsh.exe plugin --profile web add github:ArtificialAngels/dsh-frameless-page
# pinned
E:\DSH-Portable\dsh.exe plugin --profile web add github:ArtificialAngels/dsh-frameless-page#v0.1.23

# B. from the release tarball
E:\DSH-Portable\dsh.exe plugin --profile web add https://github.com/ArtificialAngels/dsh-frameless-page/releases/download/v0.1.23/dsh-frameless-page-0.1.23.tgz

# C. local tarball
E:\DSH-Portable\dsh.exe plugin --profile web add file:E:/path/to/dsh-frameless-page-0.1.23.tgz
```

For non-Portable setups replace the executable with your `dsh` and use your
actual profile name. After installing, quit DSH from the tray and relaunch it.

## Uninstall

```powershell
E:\DSH-Portable\dsh.exe plugin --profile web remove dsh-frameless-page
```

## Development

```powershell
node scripts/build-client.mjs    # rebuild lib/client.js
pnpm pack --pack-destination .artifacts
```

## License

MIT
