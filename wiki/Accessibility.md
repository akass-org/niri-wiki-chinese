## 屏幕阅读器

<sup>Since: 25.08</sup>

当 niri 作为完整桌面会话运行时，Niri 对屏幕阅读器（特别是 [Orca](https://orca.gnome.org)）有基本支持，即您需要通过显示管理器或 `niri-session` 启动 niri。
为了避免与已运行的合成器发生冲突，当 niri 作为嵌套窗口或在 TTY 上直接以 `/usr/bin/niri` 形式启动时，niri 不会暴露辅助功能接口。

我们实现了 `org.freedesktop.a11y.KeyboardMonitor` D-Bus 接口，以便 Orca 监听和捕获键盘按键，并通过 [AccessKit](https://accesskit.dev) 暴露主要的 niri UI 元素。
具体来说，niri 将会播报：

- 工作区切换，例如当您切换到第二个工作区时，它会播报“工作区 2”；
- 退出确认对话框（默认通过 <kbd>Super</kbd><kbd>Shift</kbd><kbd>E</kbd> 触发）；
- 进入截图界面和桌面概览（niri 会在这些元素获得焦点时进行播报，目前暂无其他功能）；
- 每当发生配置解析错误时；
- 重要快捷键列表（目前作为一个整体公告播报，不支持 Tab 键导航；默认通过 <kbd>Super</kbd><kbd>Shift</kbd><kbd>/</kbd> 触发）。

以下是一个演示视频，请开启声音观看。

<video controls src="https://github.com/user-attachments/assets/afceba6f-79f1-47ec-b859-a0fcb7f8eae3">

https://github.com/user-attachments/assets/afceba6f-79f1-47ec-b859-a0fcb7f8eae3

</video>

请确保 [Xwayland](./Xwayland.md) 正常工作，然后运行 `orca`。
默认配置将 <kbd>Super</kbd><kbd>Alt</kbd><kbd>S</kbd> 绑定为切换 Orca 的快捷键，这是标准的按键绑定。

请注意，这存在一些限制：

- 我们尚未实现 Alt-Tab 窗口切换器；该功能正在开发中。
- 我们还没有将焦点移动到 layer-shell 面板的快捷键绑定。添加此功能并不困难，但最好能与 LXQt/Xfce 就具体实现方式达成共识或参考先例。
- 您需要连接并启用一个显示器。没有显示器时，niri 不会给予任何窗口焦点。这对有视力的用户来说是合理的，但我不完全确定对于无障碍使用而言什么方式最合适（或许通过虚拟显示器能更好地解决此问题）。
- 您需要可用的 EGL（硬件加速）。
- 我们尚未实现屏幕遮罩功能。

如果您正在分发 niri，并希望它开箱即用地更好地支持屏幕阅读器，请考虑对默认 niri 配置进行以下更改：

- 将默认终端从 Alacritty 更改为支持屏幕阅读器的终端。例如，[GNOME Console](https://gitlab.gnome.org/GNOME/console) 或 [GNOME Terminal](https://gitlab.gnome.org/GNOME/gnome-terminal) 应该能良好工作。
- 将默认应用程序启动器和屏幕锁更改为支持屏幕阅读器的程序。例如，[xfce4-appfinder](https://docs.xfce.org/xfce/xfce4-appfinder/start) 是一个支持无障碍功能的启动器。欢迎提供更多建议！基于 GTK 的程序很可能可以正常工作。
- 添加一些 [`spawn-at-startup`](./Configuration:-Miscellaneous.md#spawn-at-startup) 命令来播放声音，以告知用户 niri 已完成加载。
- 添加 `spawn-at-startup "orca"` 以在 niri 启动时自动运行 Orca。

## 桌面缩放

目前尚未内置缩放功能，但您可以使用第三方工具，如 [wooz](https://github.com/negrel/wooz)。
