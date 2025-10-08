### 如何禁用客户端装饰/使窗口变为矩形？

在配置文件的顶层取消 [`prefer-no-csd` 设置](./Configuration:-Miscellaneous.md#prefer-no-csd) 的注释，然后重新启动您的应用程序。
之后 niri 会请求窗口省略客户端装饰，并通知它们它们正在被平铺（这会使一些窗口变为矩形，即使它们无法省略装饰并告知它们正处于平铺状态（这会使某些窗口呈矩形，即使它们无法完全移除装饰）。

请注意，目前这将阻止窗口边缘调整大小的光标手柄出现。
您仍然可以通过按住 <kbd>Mod</kbd> 和鼠标右键来调整窗口大小。

### 为什么透明窗口会被着色？/ 为什么边框/焦点环会透过半透明窗口显示出来？ {#why-are-transparent-windows-tinted-why-is-the-borderfocus-ring-showing-up-through-semitransparent-windows}

在配置文件的顶层取消注释 [`prefer-no-csd` 设置](./Configuration:-Miscellaneous.md#prefer-no-csd)，然后重新启动您的应用程序。
niri 将会在同意省略其客户端装饰的窗口周围绘制焦点环和边框。

默认情况下，焦点环和边框是作为窗口背后的纯色背景矩形渲染的。
也就是说，它们会透过半透明窗口显示出来。
这是因为使用客户端装饰的窗口可以有任意形状。

您也可以使用 [`draw-border-with-background` 窗口规则](./Configuration:-Window-Rules.md#draw-border-with-background) 来覆盖此行为。

### 如何为所有窗口启用圆角？

在您的配置中添加此窗口规则：

```kdl
window-rule {
    geometry-corner-radius 12
    clip-to-geometry true
}
```

有关更多信息，请查阅 [`geometry-corner-radius` 窗口规则](./Configuration:-Window-Rules.md#geometry-corner-radius)。

### 如何在启动时隐藏“重要快捷键”弹窗？

在您的配置中添加：

```kdl
hotkey-overlay {
    skip-at-startup
}
```

### 如何运行 Steam 或 Discord 这样的 X11 应用程序？

要运行 X11 应用程序，您可以使用 [xwayland-satellite](https://github.com/Supreeeme/xwayland-satellite)。
有关说明，请查阅 [Xwayland wiki 页面](./Xwayland.md)。

请注意，您可以通过传递正确的参数，让许多 Electron 应用程序（如 VSCode）在 Wayland 上原生运行，例如 `code --ozone-platform-hint=auto`。

### 为什么 niri 不像其他合成器那样直接集成 Xwayland？ {#why-doesnt-niri-integrate-xwayland-like-other-compositors}

这是多种因素共同作用的结果：

- 集成 Xwayland 的工作量相当大，因为合成器需要实现 X11 窗口管理器的部分功能。
- 您需要迎合 X11 的窗口化理念，而对于 niri，我希望拥有专为 Wayland 优化的最佳代码。
- niri 没有 X11 所需的良好全局坐标系。
- 您往往会得到源源不断的 X11 错误，这些错误会耗费大量时间和精力，影响其他任务的开发。
- 现如今，实际上没有那么多仅支持 X11 的客户端，而 xwayland-satellite 可以完美处理其中的大部分。
- niri 并非一个必须支持所有用例（并且有公司支持）的严肃的大型桌面环境。

总而言之，当前的情况是避免 Xwayland 集成是有利的。

<sup>Since: 25.08</sup> niri 内置了无缝的 xwayland-satellite 集成，在大多数情况下与其他合成器中的内置 Xwayland 一样有效，解决了必须手动设置的难题。

如果在将来， xwayland-satellite 成为将 Xwayland 集成到新合成器中的标准方式，我并不会感到太惊讶，因为它承担了大部分繁琐的工作，并将合成器与行为不端的客户端隔离开来。

### 我可以启用半透明窗口后面的模糊效果吗？

暂时还不支持，请关注/支持 [这个议题](https://github.com/YaLTeR/niri/issues/54)。

此外，还有一个 [PR](https://github.com/YaLTeR/niri/pull/1634) 正在为 niri 添加模糊功能，您可以手动构建和运行。
请注意，这是一个实验性的实现，可能存在问题和性能问题。

### 我可以让一个窗口置顶/固定/始终显示在所有工作区吗？

暂时还不支持，请关注/支持 [这个议题](https://github.com/YaLTeR/niri/issues/932)。

您可以通过使用 niri IPC 的脚本来模拟此功能。
例如，[nirius](https://git.sr.ht/~tsdh/nirius) 似乎具有此功能（`toggle-follow-mode`）。

### 如何让 Firefox 中的 Bitwarden 窗口作为浮动形式打开？

Firefox 似乎首先会以一个通用的 Firefox 标题打开 Bitwarden 窗口，之后才将窗口标题更改为 Bitwarden，因此您无法有效地使用 `open-floating` 窗口规则来定位它。

您需要使用脚本，例如 [这个](https://github.com/YaLTeR/niri/discussions/1599) 或其他脚本（请在 niri 议题和讨论中搜索 Bitwarden）。

### 我可以直接将窗口在当前列/在另一个窗口所在的列中打开吗？

不可以，但您可以使用 [niri IPC](./IPC.md) 编写脚本来实现您想要的行为。
监听新窗口打开的事件流，然后调用诸如 `consume-or-expel-window-left` 之类的操作。

将此功能直接添加到 niri 中具有挑战性：

- “直接在某些列中打开窗口”这一行为本身相当复杂。Niri 必须计算精确的初始窗口大小，这需要考虑列中其他窗口如何响应调整大小。这部分逻辑是存在的，但无法直接接入到计算新窗口大小的代码中。然后，它还需要处理各种边界情况，例如在目标窗口出现之前，列消失了，或有新窗口被添加到该列。
- 您如何指示一个新窗口应该在现有列（以及哪个列）中生成，而不是在新列中生成？不同的人似乎在此有不同的需求（包括基于父 PID 等的非常复杂的规则），并且从设计角度来看，究竟需要哪种（简单的）设置才是有用的，这一点非常不明确。另请参阅 https://github.com/YaLTeR/niri/discussions/1125。

### 为什么将鼠标移到显示器边缘有时会聚焦下一个窗口，但并非总是如此？

在使用 [`focus-follows-mouse`](./Configuration:-Input.md#focus-follows-mouse) 时可能会发生这种情况。
使用客户端装饰时，窗口应该在其几何区域外有一些边距，用于鼠标调整大小手柄。
这些边距“探出”了显示器边缘，因为它们在窗口几何形状之外，而当鼠标穿过这些区域时， `focus-follows-mouse` 就会触发。

但它并不总是发生：

- 一些工具包不会在窗口几何区域外放置调整大小手柄。那样的话，外部就没有输入区域，因此 `focus-follows-mouse` 没有触发的位置。
- 如果当前窗口有自己的调整大小边距，并且该边距一直延伸到显示器边缘，那么 `focus-follows-mouse` 将不会触发，因为鼠标永远不会离开当前窗口。

要解决此问题，您可以：

- 使用 `focus-follows-mouse max-scroll-amount="0%"`，这将防止在会导致滚动的情况下触发 `focus-follows-mouse`。
- 设置 `prefer-no-csd`，这通常会导致客户端移除那些调整大小的边距。

### 如何从死锁的屏幕保护程序/红屏状态中恢复？

当您的屏幕锁定程序异常退出时，您会看到一个红屏。
这是 niri 的锁定会话背景。

您可以通过启动一个新的屏幕锁定程序来恢复。
一种方法是切换到另一个 TTY（使用如 <kbd>Ctrl</kbd><kbd>Alt</kbd><kbd>F3</kbd> 这样的快捷键），然后针对 niri 的 Wayland 显示启动一个屏幕锁定程序，例如 `WAYLAND_DISPLAY=wayland-1 swaylock`。

另一种方法是在您的屏幕锁定程序绑定上设置 `allow-when-locked=true`，然后您可以在红屏上按下该快捷键来启动一个新的屏幕锁定程序。
```kdl
binds {
    Super+Alt+L allow-when-locked=true { spawn "swaylock"; }
}
```
