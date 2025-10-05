### Electron 应用

基于 Electron 的应用程序可以直接在 Wayland 上运行，但这并非默认设置。

对于 Electron > 28 版本，您可以设置一个环境变量：
```kdl
environment {
    ELECTRON_OZONE_PLATFORM_HINT "auto"
}
```

对于更早的版本，您需要向目标应用程序传递命令行参数：
```
--enable-features=UseOzonePlatform --ozone-platform-hint=auto
```

如果应用程序有 [桌面快捷方式（desktop entry）](https://specifications.freedesktop.org/menu-spec/latest/menu-add-example.html)，您可以将命令行参数放入 `Exec` 字段。

### VSCode

如果您在使用 VSCode 时遇到某些快捷键问题，请尝试启动 `Xwayland` 并为 VSCode 设置 `DISPLAY=:0` 环境变量。
也就是说，仍然使用 Wayland 后端运行 VSCode，但将 `DISPLAY` 指向正在运行的 Xwayland 实例。
显然，VSCode 当前会无条件地向 X 服务器查询键位映射。

### WezTerm

> [!NOTE]
> 这两个问题似乎在 WezTerm 的每日构建版本中都已被修复。

WezTerm 中存在 [一个 bug](https://github.com/wezterm/wezterm/issues/4708)，它会等待一个大小为零的 Wayland 配置事件，导致其窗口永远不会在 niri 中显示。临时解决方法是，在 niri 配置中添加以下窗口规则（包含在默认配置中）：

```kdl
window-rule {
    match app-id=r#"^org\.wezfurlong\.wezterm$"#
    default-column-width {}
}
```

这个空的默认列宽允许 WezTerm 选择自己的初始宽度，从而使其正确显示。

WezTerm 中存在 [另一个 bug](https://github.com/wezterm/wezterm/issues/6472)，导致它在平铺状态下选择错误的大小，并阻止用户调整其大小。
由于 niri 会使用 [`prefer-no-csd`](./Configuration:-Miscellaneous.md#prefer-no-csd) 将窗口置于平铺状态。
因此，如果您遇到此问题，请注释掉 niri 配置中的 `prefer-no-csd` 并重启 WezTerm。

### Ghidra

部分 Java 应用程序（如 Ghidra）在 xwayland-satellite 下可能显示为白屏。
要解决此问题，请使用 `_JAVA_AWT_WM_NONREPARENTING=1` 环境变量运行它们。

### Zen Browser

由于某种原因，Zen Browser 中禁用了 DMABUF 屏幕录制，因此在 niri 上无法开箱即用地使用屏幕录制功能。
要解决此问题，请在 `about:config` 中将 `widget.dmabuf.force-enabled` 设置为 `true`。

### 全屏游戏

部分游戏，无论是 Linux 原生版还是 Wine 版，在使用非堆叠式桌面环境时都会出现各种问题。
其中大多数问题可以通过 Valve 的 [gamescope](https://github.com/ValveSoftware/gamescope) 来避免，例如：

```sh
gamescope -f -w 1920 -h 1080 -W 1920 -H 1080 --force-grab-cursor --backend sdl -- <game>
```

此命令将以 1080p 全屏模式运行 *<game>* ——请确保替换宽度和高度值以匹配您所需的分辨率。
`--force-grab-cursor` 强制 gamescope 使用相对鼠标移动模式，这可以防止鼠标光标在多显示器设置下逃逸出游戏窗口。
请注意，`--backend sdl` 目前也是必需的，因为 gamescope 的默认 Wayland 后端无法正确锁定光标（可能与 https://github.com/ValveSoftware/gamescope/issues/1711 有关）。

Steam 用户应通过游戏的 [启动选项](https://help.steampowered.com/zh/faqs/view/7D01-D2DD-D75E-2955) 使用 gamescope，将游戏可执行文件替换为 `%command%`。
其他游戏启动器（如 [Lutris](https://lutris.net/)）有自己设置 gamescope 选项的方法。

使用此方法运行基于 X11 的游戏不需要 Xwayland，因为 gamescope 会创建自己的 Xwayland 服务器。
您也可以通过向 gamescope 传递 `--expose-wayland` 来运行 Wayland 原生游戏，从而彻底脱离 X11。

### Steam

在某些系统上，Steam 会显示一个完全黑色的窗口。
要解决此问题，请导航到“设置” -> “界面”（通过 Steam 的托盘图标，或盲操在窗口左上角的 Steam 菜单），然后**禁用**“在网页视图中启用 GPU 加速渲染”这个选项。
重启 Steam，现在应该可以正常工作了。

如果您不想禁用 GPU 加速渲染，可以尝试传递启动参数 `-system-composer` 来代替。

Steam 通知不通过标准通知守护进程运行，而是显示为屏幕中央的浮动窗口。
您可以通过在 niri 配置中添加窗口规则，将它们移动到更方便的位置：

```kdl
window-rule {
    match app-id="steam" title=r#"^notificationtoasts_\d+_desktop$"#
    default-floating-position x=10 y=10 relative-to="bottom-right"
}
```

### Waybar 及其他 GTK 3 组件

如果您的 Waybar 有圆角，并且角落中出现黑色像素点，请将 Waybar 的不透明度设置为 0.99，这应该可以修复此问题。

GTK 3 似乎有一个 bug，即使表面有圆角，它也会报告表面为完全不透明。
这导致 niri 会用黑色填充角落内的透明像素。

将表面不透明度设置为小于 1 的值可以解决问题，因为这样 GTK 不再报告表面为不透明。
