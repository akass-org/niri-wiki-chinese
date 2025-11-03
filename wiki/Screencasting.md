### 概述

niri 主要是通过 portals 和 pipewire 提供的屏幕录制接口。
[OBS]、Firefox、Chromium、Electron、Telegram 以及其他应用程序均支持此功能。
您可以录制整个显示器或单个窗口。

要使用此功能，您需要一个可正常工作的 D-Bus 会话、pipewire、`xdg-desktop-portal-gnome`，以及[将 niri 作为会话运行](./Getting-Started.md)（即通过 `niri-session` 或从显示管理器启动）。
在主流发行版中，这些组件通常都能“开箱即用”。

此外，您也可以使用依赖于 `wlr-screencopy` 协议的工具，niri 也支持该协议。

niri 中内置有多项专为屏幕录制设计的特性。
让我们一起来看看！

### 遮蔽窗口

您可以在屏幕录制中遮蔽特定窗口，将其替换为纯黑色的矩形区域。
这对于密码管理器或聊天窗口等场景很有用。

![截图显示一个窗口在正常情况下可见，但在 OBS 中被遮蔽。](./img/block-out-from-screencast.png)

这是通过 `block-out-from` 窗口规则控制的，例如：

```kdl
// 在屏幕录制中遮蔽密码管理器。
window-rule {
    match app-id=r#"^org\.keepassxc\.KeePassXC$"#
    match app-id=r#"^org\.gnome\.World\.Secrets$"#

    block-out-from "screencast"
}
```

您也可以使用图层规则来遮蔽图层界面：

```kdl
// 从屏幕录制中遮蔽 mako 通知。
layer-rule {
    match namespace="^notifications$"

    block-out-from "screencast"
}
```

有关更多详细信息和示例，请参阅[相应的 wiki 部分](./Configuration:-Window-Rules.md#block-out-from)。

### 动态屏幕录制目标

<sup>Since: 25.05</sup>

Niri 提供了一个特殊的屏幕录制流，您可以动态更改它。
在屏幕录制窗口对话框中，它显示为“niri 动态录制目标（niri Dynamic Cast Target）”。

![显示 niri Dynamic Cast Target 的屏幕录制对话框。](https://github.com/user-attachments/assets/e236ce74-98ec-4f3a-a99b-29ac1ff324dd)

选择该选项后，它将作为一个空的、透明的视频流启动。
然后，您可以使用以下几个绑定来更改它显示的内容：

- `set-dynamic-cast-window` 录制当前焦点窗口。
- `set-dynamic-cast-monitor` 录制当前焦点显示器。
- `clear-dynamic-cast-target` 恢复到空视频流。

您也可以从命令行调用这些操作，例如交互式选择要录制的窗口：

```sh
$ niri msg action set-dynamic-cast-window --id $(niri msg --json pick-window | jq .id)
```

<video controls src="https://github.com/user-attachments/assets/c617a9d6-7d5e-4f1f-b8cc-9301182d9634">

https://github.com/user-attachments/assets/c617a9d6-7d5e-4f1f-b8cc-9301182d9634

</video>

如果录制目标消失（例如目标窗口关闭），流将自动恢复为空状态。

所有动态录制共享同一个目标，但新的录制开始时是空视频流，直到您下次更改它（以避免意外泄露敏感内容）。

### 标示正在录制的窗口

<sup>Since: 25.02</sup>

[`is-window-cast-target=true` 窗口规则](./Configuration:-Window-Rules.md#is-window-cast-target)可匹配正在被录制的窗口。
您可以使用特殊的边框颜色来明确标示正在录制的窗口。

此功能也适用于动态屏幕录制所针对的窗口。
然而，对于在全屏屏幕录制中恰好可见的窗口，此功能则不起作用。

```kdl
// 用红色标示正在录制的窗口。
window-rule {
    match is-window-cast-target=true

    focus-ring {
        active-color "#f38ba8"
        inactive-color "#7d0d2d"
    }

    border {
        inactive-color "#7d0d2d"
    }

    shadow {
        color "#7d0d2d70"
    }

    tab-indicator {
        active-color "#f38ba8"
        inactive-color "#7d0d2d"
    }
}
```

示例：

![用红色边框和阴影标示的正在录制的窗口。](https://github.com/user-attachments/assets/375b381e-3a87-4e94-8676-44404971d893)

### 窗口化（虚拟/分离式）全屏 {#windowed-fakedetached-fullscreen}

<sup>Since: 25.05</sup>

在录制 Google Slides 这类基于浏览器的演示文稿时，您通常希望隐藏浏览器界面，这就需要将浏览器设为全屏模式。
但这样做有时很不方便，例如，当您使用超宽屏显示器时，或者您只是想让浏览器窗口小一点，而不占用整个显示器。

`toggle-windowed-fullscreen` 这个绑定就是为了解决这个问题。
它会让应用程序以为自己进入了全屏模式，但实际上它仍然是一个普通窗口，您可以自由调整其大小并将其放置在任意位置。

```kdl
binds {
    Mod+Ctrl+Shift+F { toggle-windowed-fullscreen; }
}
```

请注意，并非所有应用程序都会响应全屏操作，因此可能有时候您使用了这个绑定，却看起来无事发生。

下面是一个示例，显示了一个窗口化全屏的 Google Slides [演示文稿](https://youtu.be/Kmz8ODolnDg)，以及演讲者视图和会议应用程序：

![窗口化的 Google Slides 演示文稿，另一个窗口显示演讲者视图，还有一个窗口显示 Zoom UI 正在录制演示文稿。](https://github.com/user-attachments/assets/b2b49eea-f5a0-4c0a-b537-51fd1949a59d)

[OBS]: https://obsproject.com/
