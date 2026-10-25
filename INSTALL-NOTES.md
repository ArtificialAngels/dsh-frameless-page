# 本次安装记录（DSH-Portable 0.9.4）

安装时间：2026-10-22 20:2x（本机 `E:\DSH-Portable`，profile `web`，内核 `0.2.1-rc.2`）。

## 已落到 profile 的状态

| 位置 | 内容 |
| --- | --- |
| `data/dsh-home/profiles/web/package.json` | `dependencies["dsh-frameless-page"] = "file:E:/DSH-Portable/workspace/dsh-frameless-page/.artifacts/dsh-frameless-page-0.1.0.tgz"`；`dsh.profile.bundles` 末尾追加 `dsh-frameless-page` |
| `data/dsh-home/profiles/web/pnpm-lock.yaml` | 已由 pnpm 写入该 `file:` 依赖的解析记录（相对路径 `../../../../workspace/...`） |
| `data/dsh-home/profiles/web/node_modules/dsh-frameless-page/` | 插件运行文件（`lib/`、`locale/`、`cordis.patch.yml`、README、图标） |

备份（安装前原始文件，用于回滚）：

```
E:\DSH-Portable\workspace\dsh-frameless-page\.profile-backup\
  package.json.before        # 安装前的 profile 清单
  package.json.preinstall    # 改依赖/ bundles 之前的清单
  pnpm-lock.yaml.before      # 安装前的 lockfile
  cordis.patch.yml.before    # 安装前的 profile patch（本次没有改它）
```

## 为什么没有用 `dsh.exe plugin add`

便携版自带的 `dsh.exe plugin --profile web add file:…` 会在安装后跑一次 import 预检；该预检解析 `dsh-better-sidebar` 的 `cordis.patch.yml` 时不认识其中的 `!!js` YAML 标签，直接报：

```
dsh-better-sidebar: YAMLException: unknown tag !<tag:yaml.org,2002:js> (42:154)
Plugin configuration restored.
```

这是**便携版预检与该 profile 现有插件的既有兼容问题**，与 `dsh-frameless-page` 无关（同一命令装任何插件都会这样）。为了不再触发回滚，本次改为等价的分步安装：

1. 在 profile `package.json` 增加 `file:` 依赖，并把 `dsh-frameless-page` 加进 `dsh.profile.bundles`；
2. 用便携版自带的 pnpm（同一 store、同一 `nodeLinker: hoisted`、`--config.minimumReleaseAge=0 --prefer-offline --ignore-scripts`）在 profile 里执行 `install`，让 package.json / lockfile / node_modules 三者一致；
3. 用**真实 profile** 起一个测试宿主（只 `--patch` 关掉启动屏/桌宠/壁纸三个会挡住自动化的界面插件），验证：
   - `dsh --profile web --dump-config` 能看到 `dsh-frameless-page` 行；
   - 浏览器端 21 项 CDP 断言全部通过（见 `shots/real-profile/e2e-results.json`）；
   - 页面本身无 console 错误、无未捕获异常。

## 生效方式

插件变更不会热挂到正在运行的宿主进程：**需要重启 DSH-Portable**（托盘图标 → 退出，或窗口菜单 文件 → 退出，再打开 `DeepSeek-Herness.exe`）。重启后：

- 左侧栏底部（设置齿轮旁）出现轨道图标入口；
- 第一次进入会自动打开一次无边框页面，之后只在点按钮 / `Ctrl+Alt+G` 时打开。

## 回滚

1. 把 `.profile-backup/package.json.before`、`pnpm-lock.yaml.before`、`cordis.patch.yml.before` 复制回 profile（去掉 `.before` 后缀）；
2. `pnpm install`（或直接删除 `node_modules/dsh-frameless-page`；下次启动时 `repairIncompleteProfileDependencies` 会按清单补齐/暂停）；
3. 重启 DSH-Portable。

插件本身不写 DSH 存储、不建后台进程，回滚只需要删掉上面这几处。

## 迁移提醒

依赖 specifier 指向 `workspace/dsh-frameless-page/.artifacts/dsh-frameless-page-0.1.0.tgz`。整个 `DSH-Portable` 文件夹搬家后，**已安装的 node_modules 不受影响**；只有将来重新执行 pnpm 安装时才需要这个 tgz。若工作区被清空，先按 README 重新 `pnpm pack` 出同名 tgz，或改依赖指向新的包路径。

---

# 2026-10-22 第二次部署：原生窗口无边框 + 拖动（0.1.1 + 补丁外壳）

本轮把「无边框」从窗口内浮层升级为**原生窗口模式**，并顺手修掉了阻塞插件安装的预检 bug。

## 已落到机器上的改动

| 位置 | 内容 |
| --- | --- |
| `E:\DSH-Portable\DeepSeek-Herness.exe` | 替换为打了 frameless 补丁的 0.9.4 构建（276,992 B，sha256 `B59EA1CFF10ADE4ACADA16263F4D9CFEA4568C8E852CC37C17CC2F2265DB8464`），新增 `windowChrome / windowDrag / windowControls / windowState` 桥接能力 |
| `E:\DSH-Portable\DeepSeek-Herness.exe.stock-0.9.4-20261022` | 原版外壳（272,896 B，sha256 `7878D7...`），用于回滚 |
| profile `package.json` / `pnpm-lock.yaml` | 依赖更新为 `file:E:/DSH-Portable/workspace/dsh-frameless-page/.artifacts/dsh-frameless-page-0.1.1.tgz`，由 `dsh.exe plugin add` 写入；launcher 日志出现 `[plugin-cli] import-check-passed` |
| profile `node_modules/dsh-frameless-page` | 0.1.1（含 `lib/client.js` 原生标题栏实现） |
| 运行时预检补丁 | `portable-preflight-fix/NOTES.md`：`!!js` YAML 标签不再导致 `plugin add` 回滚 |
| 备份 | `workspace\.deploy-backup-20261022\`（原 shell、原 profile 三件套、patched shell、安装日志） |

## 生效方式（重要）

**必须完全退出并重新打开 DSH-Portable 一次**：托盘图标右键 → 退出（或 文件 → 退出），再运行 `E:\DSH-Portable\DeepSeek-Herness.exe`。重启后：

- 原生标题条消失，网页铺满整个窗口；页面顶部自绘 44px 标题栏：
  - 左侧：DeepSeek Harness / 无边框窗口；
  - 中间**正好 50% 宽**：抓取区（胶囊显示「抓取区 50%」），**按住可拖动整个窗口**，鼠标进入时抓取胶囊发光、引力球跟随、粒子场朝光标塌缩；
  - 右侧：最小化 / 最大化（还原）/ 关闭；
- 旧外壳若被恢复（例如产品更新覆盖了 exe），插件自动退回原来的窗口内浮层模式，不会出现没有标题条又拖不动的窗口。

## 验证方式

- 原生模式已在隔离环境验证（`workspace\.iso`，未触碰本机 live 数据）：窗口无原生标题条、抓取区实测 413.12 / 826.24 = 50.0000%、悬停 `data-gravity=1`、真实鼠标拖动窗口位移精确 180×120 px。截图：`shots/native/`。
- 插件安装链路验证：live profile 上真实执行 `dsh.exe plugin --profile web add file:...0.1.1.tgz` → exit 0，launcher 日志 `[plugin-cli] import-check-passed`（此前同样的命令会因 `!!js` 抛错并回滚）。

## 回滚（按需）

```powershell
# 1) 退出 DSH-Portable，然后恢复原版外壳
Remove-Item E:\DSH-Portable\DeepSeek-Herness.exe -Force
Rename-Item E:\DSH-Portable\DeepSeek-Herness.exe.stock-0.9.4-20261022 DeepSeek-Herness.exe
# 2) 卸载插件（会恢复 profile 依赖 / lockfile / bundles）
E:\DSH-Portable\dsh.exe plugin --profile web remove dsh-frameless-page
# 3) 重新打开 DSH-Portable
```

只回滚插件、保留补丁外壳也可以：卸载插件后重启，外壳会恢复原生标题条（页面不再请求无边框）。
只回滚外壳、保留插件也可以：插件检测不到 `windowChrome` 能力，自动使用浮层模式。

## 风险 / 注意

- DSH-Portable 的**产品更新会覆盖 `DeepSeek-Herness.exe`**，届时原生模式失效（插件自动退回浮层）；需要重新用 `workspace/native-shell/build-shell.ps1` 构建并替换，或等上游支持该桥接。
- 运行时缓存的预检补丁同理：产品更新重新解包 runtime capsule 后会恢复原 chunk，需要按 `portable-preflight-fix/NOTES.md` 重新应用（vendored 源码是补丁的可复现来源）。
- 原生拖动走 WinForms 标准 caption 拖拽（`ReleaseCapture + WM_NCLBUTTONDOWN/HTCAPTION`）；最大化/全屏状态通过 `window-state` 消息同步，全屏时页面标题栏自动隐藏。

---

# 2026-10-22 第三次部署：顶部居中「灵动岛」胶囊（0.1.4 + pill 外壳）

上一版整条原生标题栏隐藏、靠鼠标碰窗口顶边唤出的方案太难触发，且左上角原生菜单跟着消失。本版改为：
**外壳让内容真正铺满窗口，页面顶部中间常驻一个居中的胶囊按钮（Dynamic Island 风格）**。

## 交互

- **收起态（默认）**：顶部居中一个 55×30 的小胶囊（三个点），页面内容全屏铺满；按住胶囊可拖动整个原生窗口，双击最大化/还原。
- **悬停展开**：胶囊平滑展开成 300×30，显示 `DeepSeek Harness`、菜单按钮、最小化 / 最大化(还原) / 关闭。
- **菜单**：点菜单按钮弹出**原生**「文件 / 视图 / 帮助」命令（由外壳 `dsh-portable/window-menu` 消息弹原生 ContextMenu，命令与原生标题栏完全一致）。
- **窗口按钮**：通过 `window-control` 消息调用外壳原生最小化/最大化/关闭/全屏；最大化状态经 `window-state` 同步。
- **安全回退**：页面没有加载插件 / 不认识 `windowChrome` 能力时，外壳保持原来的整条原生标题栏，不会出现无边框又拖不动的窗口。

## 本机已部署

- `E:\DSH-Portable\DeepSeek-Herness.exe` → pill 外壳构建（282,112 B，sha256 `4F5A22B57987F70C...`），原版在 `DeepSeek-Herness.exe.stock-0.9.4-20261022`。
- profile 依赖 → `dsh-frameless-page-0.1.4.tgz`；`plugin add` 预检通过（launcher 日志 `[plugin-cli] import-check-passed`）。
- 需要**退出并重新打开 DSH-Portable** 才能看到胶囊。

## 验证（隔离环境 .iso，未触碰 live 数据）

- 页面全屏铺满：页面物理高度 1150 ≈ 窗口 1153（不再保留标题行）。
- 胶囊：收起 55×30、悬停展开 300×30，均水平居中（页面 826 CSS 宽，x=263）。
- 拖动：按住胶囊拖动，窗口位移精确 120×70 px。
- 原生菜单：点击菜单按钮出现原生「文件 / 视图 / 帮助」上下文菜单（截图 `shots/island/island-34-menu.png`）。
- 最大化/还原：经 `window-control` 消息应用到原生窗口（隔离环境实测最大化到 0,42 2560×1558）。
- 截图：`shots/island/island-31-collapsed.png`、`island-32-expanded.png`、`island-34-menu.png`。

---

# 2026-10-22 第四次部署：灵动岛 v2（更小、液体玻璃、自适应折叠）

在第三版基础上按反馈细化，全部为页面侧（插件）改动，外壳沿用 pill 构建。

## 视觉 / 交互

- **更小**：收起胶囊 77×32（v1 为 100×40），高度 32px、`border-radius:16px`——左右是完整圆形端头；尺寸用 CSS px，页面缩放（Ctrl +/-）时整体跟随缩放。
- **液体玻璃**：多层高光渐变 + `backdrop-filter: blur(22px) saturate(185%) brightness(1.04)` + 内侧 1px 高光/底影 + 外发光；胶囊顶部有镜面高光、底部有细反光。
- **三个点**：8px 红/绿/蓝圆点，各自带 **5% 不透明度自发光**（`box-shadow` 用 `color-mix(... 5%, transparent)`），并叠加极淡的内高光；会话运作时三点以 1.15s 周期交替闪烁（依次延迟 0/0.14/0.28s），像进度条。
- **悬停 0.5s 才展开**：进入胶囊先等 500ms，仍在胶囊内才展开；展开后是完整的 文件 / 视图 / 帮助 + 最小化 / 最大化(还原) / 关闭，不再显示三个点。
- **拖动不展开**：在胶囊上按下即进入原生窗口拖动，同时取消悬停计时并强制收起；拖动过程中不会因为停留而展开。
- **自适应三档**：按 `innerWidth` 判断可用宽度——足够时完整展开；不足时首按钮变 **•••**（二级菜单开关，折叠的菜单项收进去）；再不足时不展开，点击胶囊弹二级菜单；折叠时**关闭按钮固定在菜单最后**（红色危险样式）。窗口 resize / 页面缩放都会重新计算。
- **二级菜单液体玻璃**：与胶囊同一套玻璃质感（圆角 14、模糊/高光/描边一致），悬停项为半透明高光；Esc 或点击外部关闭。

## 本机部署

- 外壳 `DeepSeek-Herness.exe`：pill 构建（282,624 B，含单菜单 `window-menu {menu:"file|view|help"}` 支持）。
- 插件：`dsh-frameless-page` **0.1.7**（`plugin add` 预检通过）。
- 重启 DSH-Portable 后生效。

## 验证（隔离环境 .iso）

- 收起：77.28×32、`border-radius:16px`、`backdrop-filter: blur(22px) saturate(1.85)`、三点颜色 rgb(255,95,87)/rgb(52,199,89)/rgb(10,132,255)、自发光 5%；
- 悬停 250ms 不展开、950ms 后展开且文字为「文件 视图 帮助」；
- 按住胶囊并触发 pointerenter：`data-open` 保持 0（拖动不展开）；
- 原生文件菜单正常弹出（截图 `shots/island2/island2-34-menu.png`）；
- 截图：`shots/island2/island2-31-collapsed.png`、`island2-32-expanded.png`、`island2-33-busy.png`。


---

# 2026-10-22 第五次部署：胶囊再缩小 + 完全继承主对话框风格

- **尺寸**：收起态 66×28（上一版 77×32），`border-radius:14px`（= 高度一半，左右是完整圆形端头）；展开态 195×28。CSS px 随页面缩放（Ctrl +/-）与 DPI 一起缩放。
- **风格继承主对话框**：运行时在 composer（`textarea` / 可编辑区）附近查找圆角 ≥10、带半透明底/玻璃滤镜/描边的卡片容器，读取其 computed `background-color / backdrop-filter / box-shadow / border-color / color / font-family`，写成 CSS 变量（`--dfp-surface-*`）应用到胶囊和二级菜单；主题切换（documentElement/body 的 class/style 变化）会 350ms 防抖后重新采样。当前实测：胶囊底色 = composer 卡片 `rgb(44,44,46)`，`backdrop-filter` 继承为 `none`，阴影继承 composer 的 `0.5px ring + 4px 16px`，圆角仍保持 14px 全圆端。
- 三个 7px 红/绿/蓝点保留 5% 自发光；悬停 0.5s 展开、拖动不展开、三档自适应、二级菜单液体玻璃等沿用上一版。
- 插件版本 0.1.8；重启 DSH-Portable 生效。截图：`shots/island2/island2-41-collapsed.png`、`island2-42-expanded.png`。
---

# 2026-10-22 第六次部署：二级菜单改为新 UI + 点击外部自动关闭

- **二级菜单不再用原生 WinForms 弹层**：文件 / 视图 / 帮助 改为页面内渲染的液体玻璃面板（与胶囊同一套 `--dfp-surface-*` 继承变量、圆角 12、阴影/描边/字色一致），条目带快捷键提示；位置对齐到被点击的按钮，超出胶囊宽度会自动夹在可视范围内。
- **命令仍由原生外壳执行**：新增 `dsh-portable/window-command {id}` 桥接，外壳按 ToolStripItem.Name 递归查找原生命令并 `PerformClick()`（新会话 / 设置 / 关闭 / 重启 / 退出 / 重新加载 / 放大 / 缩小 / 实际大小 / 最大化 / 全屏 / 检查更新 / 日志 等），行为与原生菜单完全一致。
- **点击外部自动关闭**：document 捕获阶段 pointerdown，点在子菜单外（包括点胶囊其它区域、页面、其它窗口）会关闭子菜单；Esc 优先关闭子菜单，再关 ••• 面板，再收起胶囊。点菜单项执行命令后也会关闭。
- 之前原生菜单“点了别处不关”的原因：ToolStripDropDown 浮在 WebView2 之上时收不到页面点击，无法自动关闭；现在不再使用这个原生弹层。
- 部署：外壳 `DeepSeek-Herness.exe` 283,136 B（含 window-command 桥移）；插件 0.1.9；重启生效。截图：`shots/island2/island2-51-submenu.png`。
---

# 2026-10-22 第七次部署：0.15s 触发 + 去掉液态玻璃 + 完全继承主对话框

- 悬停展开触发时间 500ms → **150ms**（`HOVER_EXPAND_DELAY = 150`）；仍保留 420ms 离开收起延迟。
- **删除液态玻璃**：移除胶囊/二级菜单的 `backdrop-filter`、渐变背景、`::before/::after` 镜面高光；不再有自定义 accent 发光边框。
- **完全继承主对话框**：背景色、阴影（composer 的 0.5px ring + 4px/16px 投影）、描边色、文字颜色与字体全部取自 composer 卡片（运行时采样）；胶囊 66×28、圆角 14（全圆端头），视觉上就是主对话框的同款卡片缩成胶囊。
- 三个 7px 红/绿/蓝点保留 5% 自发光与会话运行时的交替闪烁。
- 插件版本 0.1.10；重启 DSH-Portable 生效。截图：`shots/island2/island2-73-collapsed.png`、`island2-74-expanded.png`。
---

# 2026-10-22 第八次部署：胶囊更圆 + 苹果灵动岛式展开动画

- **更圆**：`border-radius: 999px`（浏览器按高度 28 钳制为 14px 半径 = 真正半圆端头），并把左右内边距从 12 收到 10、三点间距 6→5，收起态缩到 **59×28**，直边只剩约 31px，左右两段是完整半圆。
- **展开/收起动画**（参考灵动岛的“可中断、带轻微过冲”手感）：
  - 展开 430ms，`cubic-bezier(.34,1.45,.5,1)`（先略过冲再回落，小回弹）；
  - 收起 300ms，`cubic-bezier(.4,0,.2,1)`（干净收拢）；
  - 宽度用 JS 实测的收起/展开目标宽度做数值过渡，不再用 max-width 突变；
  - 展开内容 `translateX(7px) + scaleX(.985)` → 归零，淡入 160ms，速度不快更优雅；
  - `prefers-reduced-motion` 下全部动画关闭。
  - 参考：[Dynamic Island CSS snippet](https://fwdtools.com/ui-snippets/dynamic-island/)、[好动画的七条准则](https://x181.cn/play/css-animation/great-animations/)、[灵动岛动效分析](https://ios.sspai.com/post/75830)。
- 悬停触发保持 150ms；无液态玻璃；底色/阴影/描边/文字继续完全继承主对话框。
- 插件 0.1.11；重启 DSH-Portable 生效。截图：`shots/island2/island2-81-collapsed.png`、`island2-82-expanded.png`。
---

# 2026-10-22 第九次部署：贴边插行 + 待机仅三点 + 展开也可拖 + 250ms/1.2s

- **位置**：不再固定贴窗口顶；运行时按页面头部定位——找到「智能团队 / 标准模式 / 子智能体」文字行与「对话 / 轨迹 / 上下文」tab 行，取两行文字中心的中点作为胶囊垂直中心（每 1.5s + resize 重新计算；找不到时回退 top 44px）。不再遮挡上方按钮。
- **待机只显示三个点**：`data-hover="0"` 且未展开/未开菜单时，胶囊背景、描边、阴影全部透明，只剩 6px 红/绿/蓝三点；鼠标悬浮立即出现胶囊表面，再等 **250ms** 才展开。
- **更小**：高度 28→**24**，收起态 56×24（三点 6px、间距 5、内边距 9）；展开仍是实测宽度的数值动画。
- **展开时也能拖动**：展开态下按住胶囊背景/空白区域（非按钮、非菜单项）即可拖动原生窗口；菜单/子菜单打开时同样支持。
- **收起延迟 1.2s**：展开后鼠标离开胶囊（及菜单）1.2 秒才收小；期间回来会取消收起。
- 悬停触发 0.25s；无液态玻璃；底色/描边/阴影/字体继续继承主对话框；动画仍为展开 430ms 过冲回弹、收起 300ms。
- 插件 0.1.12；重启 DSH-Portable 生效。截图：`shots/island2/island2-91-idle-dots.png`、`island2-92-expanded.png`。
---

# 2026-10-22 第十次部署：可拖边缩放 + 全圆胶囊 + 最大化隐藏竖线 + 顶端预留

- **四边可拖动改窗口大小**：captionless 外壳在 `WM_NCHITTEST` 自己返回八个方向的命中码（上 12 / 下 15 / 左 10 / 右 11 / 四角 13,14,16,17），并把 WebView 内缩从 4px 调到 6px，保证边缘有 6px 可抓取区；已用 `SendMessage(WM_NCHITTEST)` 实测：top=12 bottom=15 left=10 right=11 topleft=13 bottomright=17 center=1。
- **两边更圆**：胶囊 `border-radius:50%`（真正的椭圆端，不再有直边+圆角过渡的矩形感）；收起 56×24。
- **顶端放置 + 预留空间**：胶囊回到最顶端，上边距 = `0.25 × 胶囊宽度`（56→14px）；同时给应用根节点 `#root` 加 `padding-top: 44px`（= 边距 + 胶囊高 + 6），会话界面上框条整体下移，胶囊上方/下方都留出空间。
- **全屏/最大化隐藏竖向分界线**：插件监听 `window-state`，给 `<html>` 加 `dfp-window-maximized` / `dfp-window-fullscreen`，这两个状态下把 `#root` 内所有元素的 `border-left/right-color` 设为透明，去掉侧栏/分栏的竖线；全屏时同时去掉预留 padding（内容真正全屏）。
- 其余沿用：待机仅三点、0.25s 展开、1.2s 收起、展开态可拖动、无液态玻璃、风格继承主对话框、三档自适应、二级菜单新 UI + 点外部关闭、原生命令桥。
- 外壳 283,648 B（新增 resize 命中）；插件 0.1.13；重启生效。截图：`shots/island2/island2-a1-idle.png`、`island2-a2-expanded.png`、`island2-a3-maximized.png`。
---

# 2026-10-22 第十一次部署：撤回椭圆、左右留白归零、无预留、点击松开即展开

- **撤回椭圆**：`border-radius` 回到 `999px`（半圆端胶囊）；把左右内边距 `12px → 2px`、三点间距 `6 → 5`，收起态 **34×24**，直边只剩约 10px，两侧是完整半圆（视觉上不再是“圆角矩形”）。
- **不再预留空间**：删除 `#root` 的 `padding-top` 预留，会话界面恢复顶到窗口顶部；胶囊上边距 = `0.25 × 胶囊宽度` = 9px。
- **悬浮或单击都能展开**：悬停 250ms 展开（不变）；在胶囊上**单击**（按下→松开、位移 <4px）也会展开，触发时刻在 **pointerup**；再单击展开态背景收起。
- **拖动仍是按下并移动**：在胶囊上按住移动超过 4px 才进入原生窗口拖动，不会把拖动误判成展开。
- 其余沿用：待机仅三点、1.2s 离开后收起、四边可拖改窗口大小、最大化/全屏隐藏竖线、无液态玻璃、风格继承主对话框、三档自适应、二级菜单新 UI + 点外部关闭、原生命令桥。
- 插件 0.1.14；外壳 283,648 B；重启生效。截图：`shots/island2/island2-b1-idle.png`、`island2-b2-expanded.png`。
---

# 2026-10-22 第十二次部署：收起态直边归零（正圆）

- 收起胶囊改为**正圆**：`--dfp-h:26px`，收起宽度强制等于高度 → **26×26**，`border-radius:999px` 钳制后直边长度 = 0；上边距 0.25×26 ≈ **7px**。
- 三点缩到 5px、间距 2px、内边距 2px，正好落在圆内；待机仍只显示三个点（圆面透明），悬浮时圆面出现，250ms 后展开成半圆端胶囊。
- 其余行为不变：无预留空间、单击松开展开/再单击收起、按住移动>4px 拖动窗口、四边缩放、最大化/全屏隐藏竖线、风格继承主对话框。
- 插件 0.1.15；重启生效。截图：`shots/island2/island2-c1-idle.png`。
---

# 2026-10-22 第十三次部署：移除引力页面 + 新/老UI切换

- **删除「引力页面」**：删掉 `src/core.js`（浮层页面实现）、`preview/`、`scripts/e2e.mjs`、`scripts/smoke.mjs`，`src/entry.js` 重写为只挂灵动岛；不再注册侧栏入口、`shell.overlay` 与 `Ctrl+Alt+G` 快捷键；`build-client.mjs` 只拼接 native-chrome + entry（bundle 从 ~106KB 降到 ~45KB）。页面 DOM 实测已无 `.dfp-launch` / `.dfp-host`。
- **切换新/老UI**：
  - 胶囊展开行依次是：文件 ｜ **切换至老UI** ｜ 视图 ｜ 帮助 ｜ 最小化/最大化/关闭。
  - 原生标题栏的「视图」菜单第一项是 **切换至新UI**。
  - 外壳新增 `chrome-ui.json` 持久化（`stateRoot\data\chrome-ui.json`，`{"mode":"pill"|"native"}`），重启后保持上次选择；新增桥消息 `dsh-portable/ui-mode {mode}`；`window-state` 增加 `uiMode` 字段。
  - 老UI（native）下胶囊隐藏、原生标题栏恢复；新UI（pill）下胶囊显示、原生标题栏移出布局。
- 外壳 285,184 B；插件 0.1.16；重启生效。截图：`shots/island2/island2-d1-old-ui.png`（老UI）、`island2-d3-new-ui.png`（新UI）。
---

# 2026-10-23 第十四次部署：原版对照 + 旧UI可拖 + iOS风标题条 + 新UI全屏不丢

- **拉取原版对照**：下载 GitHub `WSL043/DSH-Portable` 标签 `v0.9.4` 源码到 `workspace/research/upstream-0.9.4/DSH-Portable-0.9.4`，与 `research/shell-0.9.4` 逐文件比对，确认原版功能基线与当前外壳一致（此前漏掉的是 `DesktopTitleStrip.WndProc` 的命中测试覆写）。
- **旧UI（原生标题条）恢复拖动**：还原 `DesktopTitleStrip.WndProc`——标题条空白处的 `WM_NCHITTEST` 返回 `HTTRANSPARENT(-1)`，由主窗口返回 `HTCAPTION(2)`，因此空白处可拖动、双击最大化、右键系统菜单恢复。实测：strip 空白 hit=-1，主窗口同点 hit=2。
- **旧UI 改 iOS 风格**：标题条高度 36→34；左侧三个 12px 红/黄/绿「交通灯」圆点（关闭 / 最小化 / 最大化），点击生效；右侧 Windows 字形按钮移除；保留 文件/视图/帮助 菜单与 侧栏/后退/前进 导航。
- **新UI 拖动增强**：胶囊按下时 `setPointerCapture`，任意非按钮区域按住移动 >3px 都会触发原生窗口拖动（不再因为鼠标快速移出胶囊而失效）；单击（松开）仍是展开/收起。
- **F11 全屏不再丢按钮**：全屏时胶囊保持可见；在全屏下点击胶囊（或按 Esc）退出全屏；不再随全屏隐藏。
- 外壳 285,696 B；插件 0.1.17；重启生效。截图：`shots/island2/island2-e1-ios-old-ui.png`、`island2-e2-fullscreen.png`。
---

# 2026-10-23 第十五次部署：iOS 交通灯（右侧/实心色）+ 悬浮只描边、点击才展开

- 旧UI 标题条：三个交通灯移到**右侧**（Right 对齐），采用 iOS 系统色实心绘制：红 `#FF453A`（关闭）/ 黄 `#FFD60A`（最小化）/ 绿 `#30D158`（最大化）；由 `DesktopTitleRenderer.OnRenderItemText` 直接 FillEllipse（14px 抗锯齿圆点），不再用字体字形，颜色更实、更大。
- 新UI：**悬浮不再展开**，鼠标移入只显示胶囊描边（背景保持透明）；**单击（松开）才展开**，展开态单击背景收起；按住移动 >3px 仍是拖动窗口。
- 其余沿用：待机仅三点、1.2s 离开收起、F11 全屏胶囊仍可见并可点击退出、四边缩放、最大化/全屏隐藏竖线、新老UI切换与持久化。
- 外壳 286,208 B；插件 0.1.18；重启生效。截图：`shots/island2/island2-f8-ios-right.png`。
---

# 2026-10-23 第十六次部署：右侧交通灯间距/顺序/悬停符号 + 胶囊长度/厚度/上移 + 缩小完成才出点

- 旧UI 右侧交通灯：按钮间距加宽到「一个按钮的宽度」（Margin 11+11=22px）；视觉顺序从左到右为 **黄(最小化) / 绿(最大化或还原) / 红(关闭)**；悬停/按下时在圆点内绘制提示形状：`−`、`□`、`×`（深色描边）。
- 新UI 胶囊：
  - 缩小（收起）时先隐藏三个圆点，等 300ms 宽度动画结束（`data-collapsing`，320ms 后移除）才显示圆点。
  - 长度 = **1.5 × 三点总长**（三点 5px/间距 2px ≈ 19 → 收起宽 30），厚度从 26 降到 **22**。
  - 整体再上移一个圆点直径（5px）：上边距 = `0.25×宽 − 5`，实测 top=3px。
  - 展开态按钮/图标/分隔线同步缩小（行宽收窄）。
- 外壳 286,720 B；插件 0.1.19；重启生效。截图：`shots/island2/island2-g1-ios-right2.png`。
---

# 2026-10-23 第十七次部署：旧UI 交通灯回归紧凑并整体内移 + 新UI 圆点/边框居中且加长

- 旧UI：撤回上一版 22px 大间距，恢复紧凑间距（Margin 2px）；通过标题条右侧 Padding=11px 把三个按钮**整体向中间移动 0.5 个按钮宽度**（0.5×22≈11px）。顺序仍为 黄(最小化) / 绿(最大化) / 红(关闭)，悬停符号保留。
- 新UI：收起态把三个圆点与胶囊边框**居中对齐**（胶囊 flex 居中 + 收起时隐藏 row，避免隐藏的工具栏撑开布局；实测 island 中心与圆点中心差 0）；胶囊边框长度再 +1 个圆点直径（5px）：收起 **35×22**，top=4px。
- 其余不变：缩小完成后才显示三点、悬浮只描边、点击展开、四边缩放、全屏可退出等。
- 外壳 286,720 B；插件 0.1.20；重启生效。截图：`shots/island2/island2-g2-ios-right3.png`。
---

# 2026-10-23 第十八次部署：旧UI 交通灯直径 14 → 18px

- 旧UI 右侧三个圆点直径从 14px 提高到 **18px**（按钮 item 25×26，Right 对齐，间距仍紧凑，右侧内边距 12px = 0.5 按钮宽）。
- 悬停提示形状（− / □ / ×）按圆点尺寸等比放大；点击功能不变。
- 外壳 286,720 B（插件仍 0.1.20）；重启生效。截图：`shots/island2/island2-g3-ios-dots18.png`。
---

# 2026-10-23 第十九次部署：去掉窗口四边的白色 DWM 边线

- 原因：无边框窗口仍由 DWM 绘制 1px 系统边框线（`DWMWA_BORDER_COLOR`）。原代码用**托盘/外壳主题**算边线颜色（浅色主题下是 184/211 的浅灰≈白），而页面用的是深色主题，于是深浅不一致时四周出现白色细线；另外左侧/右侧/底部的 6px resize 内缩显示的是窗体 BackColor，浅色时也会发白。
- 修复：`DesktopBorderColor()` 统一返回 `DWMWA_COLOR_NONE (0xFFFFFFFE)`，让 DWM 只保留圆角裁剪和阴影、不再画边框线；resize 内缩继续用主题背景色，与页面一致。
- 实测屏幕像素：窗口左/右边缘已从 (248,248,248)/(255,255,255) 变为页面深色 (27,27,28)/(21,21,23)。
- 外壳 286,720 B；插件 0.1.20；重启生效。
---

# 2026-10-23 第二十次部署：新UI 页面顶部 10% 非按钮区域可拖动窗口

- 新UI（胶囊模式）下，document 捕获阶段监听 pointerdown/move：只要指针在视口**上方 10%** 内、且目标不是交互控件（button/a/input/textarea/select/summary/label、contenteditable、role=button/menuitem/tab/checkbox/switch/textbox/slider/combobox、`data-no-window-drag`），按住并移动 >3px 就发 `window-drag` 让外壳拖动窗口。
- 单击（不移动）不会拖窗口，保持页面原本点击行为；胶囊本身区域与原生按钮仍走各自逻辑；老UI（native 模式）不启用该区域。
- 插件 0.1.21；外壳仍 286,720 B；重启生效。
---

# 2026-10-23 第二十一次部署：顶部拖动区 10% → 5%

- 新UI 顶部窗口拖动区由视口高度 10% 收窄到 **5%**（`innerHeight * 0.05`），其余规则不变（非交互控件、移动 >3px 才触发、老UI 不启用）。
- 插件 0.1.22；外壳仍 286,720 B；重启生效。
---

# 2026-10-23 第二十二次部署：顶部 5% 双击最大化/还原

- 新UI 顶部 5% 区域内**双击**（任意位置，胶囊自身除外）直接发送 `window-control maximize`，即最大化/还原；捕获阶段 preventDefault，避免误触其它双击行为。
- 与顶部拖动区（移动 >3px 才拖）共存：单击不移动不触发、拖动拖窗口、双击最大化。
- 插件 0.1.23；外壳 286,720 B 不变；重启生效。