### 概述

Niri 提供了一些仅用于调试或实验性的选项，这些选项存在已知问题。
它们不适用于正常使用。

> [!CAUTION]
> 这些选项**不**受[配置破坏性变更策略](./Configuration:-Introduction.md#breaking-change-policy)的约束。
> 它们可能在任何时候更改或停止工作，且不会提前通知。

以下是所有选项的概览：

```kdl
debug {
    preview-render "screencast"
    // preview-render "screen-capture"
    enable-overlay-planes
    disable-cursor-plane
    disable-direct-scanout
    restrict-primary-scanout-to-matching-format
    render-drm-device "/dev/dri/renderD129"
    ignore-drm-device "/dev/dri/renderD128"
    ignore-drm-device "/dev/dri/renderD130"
    force-pipewire-invalid-modifier
    dbus-interfaces-in-non-session-instances
    wait-for-frame-completion-before-queueing
    emulate-zero-presentation-time
    disable-resize-throttling
    disable-transactions
    keep-laptop-panel-on-when-lid-is-closed
    disable-monitor-names
    strict-new-window-focus-policy
    honor-xdg-activation-with-invalid-serial
    skip-cursor-only-updates-during-vrr
    deactivate-unfocused-windows
    keep-max-bpc-unchanged
}

binds {
    Mod+Shift+Ctrl+T { toggle-debug-tint; }
    Mod+Shift+Ctrl+O { debug-toggle-opaque-regions; }
    Mod+Shift+Ctrl+D { debug-toggle-damage; }
}
```

### `preview-render`

使 niri 以与屏幕录制或屏幕捕获相同的方式渲染显示器。

可用于预览 `block-out-from` 窗口规则的效果。

```kdl
debug {
    preview-render "screencast"
    // preview-render "screen-capture"
}
```

### `enable-overlay-planes`

启用直接扫描输出到覆盖层平面（overlay planes）。
在某些硬件上，这可能导致在某些动画期间掉帧（这也是为什么它不默认开启）。

直接扫描输出到主平面（primary plane）则始终是开启的。

```kdl
debug {
    enable-overlay-planes
}
```

### `disable-cursor-plane`

禁用光标平面（cursor plane）的使用。
光标将与帧的其余部分一起渲染。

可用于解决特定硬件上的驱动程序错误。

```kdl
debug {
    disable-cursor-plane
}
```

### `disable-direct-scanout`

禁用直接扫描输出到主平面和覆盖层平面。

```kdl
debug {
    disable-direct-scanout
}
```

### `restrict-primary-scanout-to-matching-format`

仅当窗口缓冲区的格式与合成交换链（swapchain）格式完全一致时，才允许向主平面做直接扫描输出。

此标志可以避免在合成和扫描输出之间出现意外的带宽波动。
计划在未来实现一种告知客户端合成交换链格式的方法后，将其设为默认选项。
就目前而言，它可能会阻止某些客户端（比如我机器上的 mpv）扫描输出到主平面。

```kdl
debug {
    restrict-primary-scanout-to-matching-format
}
```

### `render-drm-device`

覆写 niri 将用于所有渲染的 DRM 设备。

您可以设置此项以让 niri 使用与默认设备不同的主 GPU。

```kdl
debug {
    render-drm-device "/dev/dri/renderD129"
}
```

### `ignore-drm-device`

<sup>Since: next release</sup>

列出 niri 将忽略的 DRM 设备。
在进行 GPU 直通且不希望 niri 打开特定设备时很有用。

```kdl
debug {
    ignore-drm-device "/dev/dri/renderD128"
    ignore-drm-device "/dev/dri/renderD130"
}
```

### `force-pipewire-invalid-modifier`

<sup>Since: 25.01</sup>

强制 PipeWire 屏幕录制使用无效修饰符，即使 DRM 提供了更多修饰符。

对于测试由不支持修饰符的驱动程序触发的无效修饰符代码路径很有用。

```kdl
debug {
    force-pipewire-invalid-modifier
}
```

### `dbus-interfaces-in-non-session-instances`

让 niri 即使未以 `--session` 启动，也创建其 D-Bus 接口。

方便调试录屏相关改动，无需重登录。

当您关闭测试实例时，主 niri 实例目前*不会*回收接口，因此最终您需要重新登录才能使屏幕录制再次工作。

```kdl
debug {
    dbus-interfaces-in-non-session-instances
}
```

### `wait-for-frame-completion-before-queueing`

等待每一帧完成渲染后再将其交给 DRM。

对于诊断某些同步和性能问题很有用。

```kdl
debug {
    wait-for-frame-completion-before-queueing
}
```

### `emulate-zero-presentation-time`

模拟从 DRM 返回的零（未知）呈现时间。

这在 NVIDIA 专有驱动程序上是一个问题，因此可以使用此标志来测试 niri 在这些系统上不会出现严重问题。

```kdl
debug {
    emulate-zero-presentation-time
}
```

### `disable-resize-throttling`

<sup>Since: 0.1.9</sup>

禁用向窗口发送的尺寸调整事件节流。

默认情况下，在快速调整尺寸时（例如，交互式），窗口必须先提交上一次请求的尺寸，才会收到新的尺寸事件。
这是调整大小事务正常工作所必需的，并且也有助于某些不批量处理来自合成器的传入调整大小的客户端。

禁用调整尺寸节流将以最快速度将调整尺寸事件发送到窗口，这可能非常快（例如，使用 1000 Hz 的鼠标时）。

```kdl
debug {
    disable-resize-throttling
}
```

### `disable-transactions`

<sup>Since: 0.1.9</sup>

禁用事务（调整大小和关闭）。

默认情况下，必须一起调整大小的窗口会一起调整大小。
例如，列中的所有窗口必须同时调整大小，以保持组合的列高度等于屏幕高度，并保持相同的窗口宽度。

事务使 niri 等待所有窗口完成调整大小，然后在一个同步的帧中将它们全部显示在屏幕上。
为了使它们正常工作，不应禁用调整大小节流（使用先前的调试标志）。

```kdl
debug {
    disable-transactions
}
```

### `keep-laptop-panel-on-when-lid-is-closed`

<sup>Since: 0.1.10</sup>

默认情况下，当笔记本电脑盖关闭时，niri 将禁用笔记本电脑内置的显示器。
此标志会关闭此行为，并将保持内置的显示器开启。

```kdl
debug {
    keep-laptop-panel-on-when-lid-is-closed
}
```

### `disable-monitor-names`

<sup>Since: 0.1.10</sup>

禁用制造商/型号/序列号显示器名称，就像 niri 无法从 EDID 读取它们一样。

使用此标志来解决 0.1.9 和 0.1.10 版本中连接两个具有相同制造商/型号/序列号的显示器时出现的崩溃问题。

```kdl
debug {
    disable-monitor-names
}
```

### `strict-new-window-focus-policy`

<sup>Since: 25.01</sup>

禁用对新窗口的启发式自动聚焦。
只有使用有效的 xdg-activation 令牌自行激活的窗口才会被聚焦。

```kdl
debug {
    strict-new-window-focus-policy
}
```

### `honor-xdg-activation-with-invalid-serial`

<sup>Since: 25.05</sup>

像 Discord 和 Telegram 这样常用的客户端，在用户点击其托盘图标或通知时，会生成新的 xdg-activation 令牌。
大多数情况下，这些新令牌将具有无效的序列号，因为应用程序需要被聚焦才能获得有效的序列号，而如果用户点击托盘图标或通知，通常是因为应用程序*未被*聚焦，而用户想要聚焦它。

默认情况下，niri 忽略具有无效序列号的 xdg-activation 令牌，以防止窗口随机窃取焦点。
此调试标志使 niri 接受此类令牌，使上述常用的应用程序在点击其托盘图标或通知时获得焦点。

有趣的是，点击通知会向应用程序发送一个来自通知守护程序的完全有效的激活令牌，但这些应用程序似乎完全忽略了它。
也许未来这些应用程序/工具包（Electron、Qt）会被修复，使此调试标志变得不必要。

```kdl
debug {
    honor-xdg-activation-with-invalid-serial
}
```

### `skip-cursor-only-updates-during-vrr`

<sup>Since: 25.08</sup>

在可变刷新率激活期间，跳过仅因光标输入而重绘屏幕。

对于内部未绘制光标的游戏非常有用，可以防止因光标移动而导致不稳定的 VRR 变化。

请注意，当前的实现存在一些问题，例如，当没有任何东西重绘屏幕（如游戏）时，渲染将看起来完全冻结（因为光标移动不会导致重绘）。

```kdl
debug {
    skip-cursor-only-updates-during-vrr
}
```

### `deactivate-unfocused-windows`

<sup>Since: 25.08</sup>

某些客户端（特别是基于 Chromium 和 Electron 的客户端，如 Teams 或 Slack）错误地使用 Activated xdg 窗口状态而不是键盘焦点来决定是否为新消息发送通知，或决定在哪里显示 IME 弹出窗口等事项。
Niri 在未聚焦的工作空间和不可见的标签页窗口上保持 Activated 状态（以减少不必要的动画），从而暴露了这些应用程序中的错误。

设置此调试标志以解决这些问题。
它将导致 niri 为所有未聚焦的窗口丢弃 Activated 状态。

```kdl
debug {
    deactivate-unfocused-windows
}
```

### `keep-max-bpc-unchanged`

<sup>Since: 25.08</sup>

连接显示器时，niri 会将其最大 bpc 设置为 8，以减少显示带宽并可能允许同时连接更多显示器。
将 bpc 限制为 8 不是问题，因为我们尚不支持 HDR 或色彩管理，无法真正利用更高的 bpc。

显然，将最大 bpc 设置为 8 会破坏某些由 AMDGPU 驱动的显示器。
如果您遇到这种问题，请设置此调试标志，这将阻止 niri 更改最大 bpc。
AMDGPU 错误报告：https://gitlab.freedesktop.org/drm/amd/-/issues/4487。

```kdl
debug {
    keep-max-bpc-unchanged
}
```

### 按键绑定

这些不是调试选项，而是按键绑定。

#### `toggle-debug-tint`

将所有表面着色为绿色，除非它们正在被直接扫描输出。

用于检查直接扫描输出是否正常工作。

```kdl
binds {
    Mod+Shift+Ctrl+T { toggle-debug-tint; }
}
```

#### `debug-toggle-opaque-regions`

<sup>Since: 0.1.6</sup>

将标记为不透明的区域着色为蓝色，其余渲染元素着色为红色。

用于检查 Wayland 表面和内部渲染元素如何将其部分标记为不透明，这是一种渲染性能优化。

```kdl
binds {
    Mod+Shift+Ctrl+O { debug-toggle-opaque-regions; }
}
```

#### `debug-toggle-damage`

<sup>Since: 0.1.6</sup>

将损坏区域着色为红色。

```kdl
binds {
    Mod+Shift+Ctrl+D { debug-toggle-damage; }
}
```
