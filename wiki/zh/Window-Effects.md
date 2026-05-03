### 概述

<sup>Since: 26.04</sup>

你可以将背景效果应用于窗口和 layer-shell 界面。
这些效果包括模糊（blur）、xray、饱和度（saturation）和噪点（noise）。
它们可以在 [窗口](./Configuration:-Window-Rules.md#background-effect) 或 [图层](./Configuration:-Layer-Rules.md#background-effect) 规则的 `background-effect {}` 部分中启用。

![带模糊效果的截图](./img/blur.png)

窗口需要是半透明的才能看到背景效果（否则不透明的窗口会完全遮挡住它）。
焦点环和边框也会遮挡背景效果，参见 [此 FAQ 条目](./FAQ.md#why-are-transparent-windows-tinted-why-is-the-borderfocus-ring-showing-up-through-semitransparent-windows) 了解如何更改此行为。

### 模糊

窗口和图层界面可以通过 [`ext-background-effect` 协议](https://wayland.app/protocols/ext-background-effect-v1) 请求将其背景模糊化。
这种情况下，应用程序通常会提供一些"背景模糊"设置，你需要在它的配置中启用。

你也可以在 niri 侧通过 `blur true` 背景效果窗口规则来启用模糊：

```kdl
// 在 Alacritty 终端后面启用模糊。
window-rule {
    match app-id="^Alacritty$"

    background-effect {
        blur true
    }
}

// 在 fuzzel 启动器后面启用模糊。
layer-rule {
    match namespace="^launcher$"

    background-effect {
        blur true
    }
}
```

通过窗口规则启用的模糊将遵循通过 [`geometry-corner-radius`](./Configuration:-Window-Rules.md#geometry-corner-radius) 设置的窗口圆角半径。
另一方面，通过 `ext-background-effect` 启用的模糊将精确遵循窗口请求的形状。
如果窗口或图层具有客户端圆角或其他复杂形状，它应该通过 `ext-background-effect` 设置相应的模糊形状，这样就可以获得正确形状的背景模糊，无需手动配置 niri。

窗口也可以使用 `ext-background-effect` 来模糊其弹出菜单。
在 niri 侧，你可以通过 [`window-rule`](./Configuration:-Window-Rules.md#popups) 和 [`layer-rule`](./Configuration:-Layer-Rules.md#popups) 中的 `popups` 块来实现。
请参阅这些 wiki 页面了解示例和限制。

全局模糊设置在 [`blur {}` 配置部分](./Configuration:-Miscellaneous.md#blur) 中配置，并应用于所有背景模糊。

### Xray

Xray 使窗口背景"穿透"到你的壁纸，忽略下方所有其他窗口。
你可以通过 `xray true` 背景效果 [窗口](./Configuration:-Window-Rules.md#background-effect) 或 [图层](./Configuration:-Layer-Rules.md#background-effect) 规则来启用它。

如果任何其他背景效果（如模糊）处于活动状态，xray 会默认自动启用。
这是因为它高效得多：启用 xray 后，niri 只需要对背景进行一次模糊处理，然后就可以复用这个模糊版本而无需额外工作（因为壁纸变化非常少）。

如果你有动态壁纸，xray 仍然需要每帧重新计算模糊，但这只会发生一次并在所有窗口之间共享，而不是为每个窗口单独重新计算。

#### 非 xray 效果（实验性）

你可以通过 `xray false` 背景效果窗口规则来禁用 xray。
这将提供普通类型的模糊效果，即窗口下方的所有内容都被模糊。
请记住，非 xray 模糊和其他非 xray 效果开销更大，因为每当你移动窗口或下方内容发生变化时，niri 都必须重新计算它们。

> [!WARNING]
> 非 xray 效果目前是实验性的，因为它们存在一些已知限制。
>
> - 它们在窗口打开/关闭动画期间以及拖动平铺窗口时会消失。
> 修复此问题需要重构 niri 渲染代码以延迟离屏渲染，可能还需要其他重构。

### 实现说明

`ext-background-effect` 协议支持任意 wl_surface。
我们目前仅为顶层窗口、图层界面和弹出窗口实现了它，这应该覆盖了应用程序实际使用的绝大多数场景。

对于弹出窗口，效果默认为*非 xray*，因为弹出窗口通常显示在窗口之上。

特别地，以下 surface 类型不支持 `ext-background-effect`。
它们可以在有需要时再实现。

- Subsurface。需要为背景效果实现 `clip-to-geometry` 支持。
- 锁屏界面。没有实际用途，因为它只会显示我们的红色锁定会话背景。
- 光标和拖放图标。
这里的主要挑战是光标是单独渲染的屏幕录制场景。
这是有问题的，因为非 xray 效果需要一次性渲染整个场景，而不是单独渲染。
