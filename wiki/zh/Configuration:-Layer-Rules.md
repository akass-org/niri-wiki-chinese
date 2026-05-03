### 概述

<sup>Since: 25.01</sup>

图层规则允许您为单个 layer-shell 界面调整行为。
它们包含 `match` 和 `exclude` 指令，用于控制规则应该应用于哪些 layer-shell 界面，并提供了一系列可供您设置的属性。

图层规则的处理和工作方式与窗口规则非常相似，只是匹配器和属性不同。
请阅读[窗口规则的 wiki 页面](./Configuration:-Window-Rules.md)以了解匹配是如何工作的。

以下是图层规则可以拥有的所有匹配器和属性：

```kdl
layer-rule {
    match namespace="waybar"
    match at-startup=true
    match layer="top"

    // 持久生效的属性。
    opacity 0.5
    block-out-from "screencast"
    // block-out-from "screen-capture"

    shadow {
        on
        // off
        softness 40
        spread 5
        offset x=0 y=5
        draw-behind-window true
        color "#00000064"
        // inactive-color "#00000064"
    }

    geometry-corner-radius 12
    place-within-backdrop true
    baba-is-float true

    background-effect {
        xray true
        blur true
        noise 0.05
        saturation 3
    }

    popups {
        opacity 0.5
        geometry-corner-radius 6

        background-effect {
            xray true
            blur true
            noise 0.05
            saturation 3
        }
    }
}
```

### 图层界面匹配

让我们更仔细地看一下这些匹配器。

#### `namespace`

这是一个正则表达式，应匹配界面命名空间中的任何位置。
您可以阅读[此处文档](https://docs.rs/regex/latest/regex/#syntax)了解支持的正则表达式语法。

```kdl
// 匹配命名空间包含 "waybar" 的界面，
layer-rule {
    match namespace="waybar"
}
```

您可以通过运行 `niri msg layers` 找到所有打开的 layer-shell 界面的命名空间。

#### `at-startup`

可以是 `true` 或 `false`。
在启动 niri 后的前 60 秒内进行匹配。

```kdl
// 在 niri 启动时以 0.5 的不透明度显示 layer-shell 界面，之后不再显示。
layer-rule {
    match at-startup=true

    opacity 0.5
}
```

#### `layer`

<sup>Since: 26.04</sup>

匹配位于此 layer-shell 层上的界面。
可设置为 `"background"`、`"bottom"`、`"top"` 或 `"overlay"`。

```kdl
// 让所有 overlay 层的界面浮起来。
layer-rule {
    match layer="overlay"

    baba-is-float true
}
```

### 动态属性

这些属性会持续应用于已打开的 layer-shell 界面。

#### `block-out-from`

您可以阻止 xdg-desktop-portal 屏幕录制或所有屏幕捕获捕获界面。
它们将被替换为纯黑色矩形。

这对于通知可能很有用。

同样的注意事项和说明适用于 [`block-out-from` 窗口规则](./Configuration:-Window-Rules.md#block-out-from)，因此请查看那里的文档。

![截图显示一个通知在正常情况下可见，但在 OBS 中被屏蔽。](./img/layer-block-out-from-screencast.png)

```kdl
// 阻止 mako 通知被屏幕录制捕获。
layer-rule {
    match namespace="^notifications$"

    block-out-from "screencast"
}
```

#### `opacity`

设置界面的不透明度。
`0.0` 是完全透明，`1.0` 是完全不透明。
这是在界面自身的不透明度之上应用的，因此半透明的界面将变得更加透明。

不透明度会单独应用于 layer-shell 界面的每个子项，因此子界面和弹出菜单将显示其后面的窗口内容。

```kdl
// 让 fuzzel 半透明。
layer-rule {
    match namespace="^launcher$"

    opacity 0.95
}
```

#### `shadow`

<sup>Since: 25.02</sup>

为界面覆盖阴影选项。

这些规则的选项与布局部分中的常规 [`shadow` 配置](./Configuration:-Layout.md#shadow)相同，因此请查阅那里的文档。

与窗口阴影不同，图层界面的阴影必须通过一条图层规则来启用。
也就是说，在布局配置部分启用阴影，并不会自动为图层界面启用它们。

> [!NOTE]
> 图层界面无法告知 niri 其*视觉几何形状*。
> 例如，如果图层界面包含一些不可见的边距（如 mako），niri 无法知道这一点，并将在整个界面（包括不可见的边距）后面绘制阴影。
>
> 因此，要使用 niri 阴影，您需要配置 layer-shell 客户端以移除它们自己的边距或阴影。

```kdl
// 为 fuzzel 添加阴影。
layer-rule {
    match namespace="^launcher$"

    shadow {
        on
    }

    // Fuzzel 默认设置为 10 像素圆角。
    geometry-corner-radius 10
}
```

#### `geometry-corner-radius`

<sup>Since: 25.02</sup>

设置界面的圆角半径。

此设置仅影响阴影——它将使阴影的角落变圆以匹配几何圆角半径。

```kdl
layer-rule {
    match namespace="^launcher$"

    geometry-corner-radius 12
}
```

#### `place-within-backdrop`

<sup>Since: 25.05</sup>

设置为 `true` 可将该界面放置到在[概览](./Overview.md)和工作区之间可见的背景中。

这仅适用于忽略独占区域的*背景*图层界面（壁纸工具的典型情况）。
背景内的图层将忽略所有输入。

```kdl
// 将 swaybg 放入概览背景中。
layer-rule {
    match namespace="^wallpaper$"

    place-within-backdrop true
}
```

#### `baba-is-float`

<sup>Since: 25.05</sup>

让您的图层界面上下浮动。

这个功能是[2025 年愚人节功能](./Configuration:-Window-Rules.md#baba-is-float)的正统续作。

```kdl
// 让 fuzzel 浮起来。
layer-rule {
    match namespace="^launcher$"

    baba-is-float true
}
```

#### `background-effect`

<sup>Since: 26.04</sup>

覆盖此界面的背景效果选项。

- `xray`：设置为 `true` 以启用 xray 效果，或设置为 `false` 以禁用它。
- `blur`：设置为 `true` 以启用此界面后面的模糊效果，或设置为 `false` 以强制禁用它。
- `noise`：添加到背景上的像素噪点数量（有助于减轻模糊产生的色带问题）。
- `saturation`：背景的颜色饱和度（`0` 为去饱和，`1` 为正常，`2` 为 200% 饱和度）。

请参见 [窗口效果页面](./Window-Effects.md) 了解背景效果的概述。

```kdl
// 使 top 和 overlay 层使用常规模糊（如果已启用），
// 而 bottom 和 background 层继续使用高效的 xray 模糊。
layer-rule {
    match layer="top"
    match layer="overlay"

    background-effect {
        xray false
    }
}
```

#### `popups`

<sup>Since: 26.04</sup>

覆盖此 layer-shell 界面的弹出窗口（例如点击 Waybar 中的某个项目所打开的菜单）的属性。

这些属性的工作方式与对应的图层规则属性相同，不同之处在于它们应用于界面的弹出窗口而非界面本身。

`opacity` 会*叠加*在界面自身的透明度规则之上，因此同时设置两者将使得弹出窗口比界面本身更透明。
其他属性独立应用。

> [!NOTE]
> 此块仅影响应用通过 Wayland 的 [xdg-popup](https://wayland.app/protocols/xdg-shell#xdg_popup) 创建的弹出窗口（这应该涵盖了大多数情况）。
>
> 一些桌面 shell 会通过在常规 layer-shell 界面中绘制看起来像弹出窗口的内容来模拟弹出窗口。
> 从 niri 的角度来看，这些只是 layer-shell 界面而非弹出窗口，因此此块不会对它们生效。
>
> 此块也不会影响输入法弹出窗口，例如 Fcitx。

```kdl
// 模糊 Waybar 弹出菜单后面的背景。
layer-rule {
    match namespace="^waybar$"

    popups {
        // 匹配默认的 GTK 3 弹出窗口圆角半径。
        geometry-corner-radius 6
        opacity 0.85

        background-effect {
            blur true
        }
    }
}
```

请记住，只有当弹出窗口的形状为（圆角）矩形，并且 layer-shell 界面正确地将其 Wayland 几何区域设置为排除任何阴影时，背景效果才能正确显示。
具有自定义形状的弹出窗口需要应用实现 [ext-background-effect protocol](https://wayland.app/protocols/ext-background-effect-v1) 才能正确运作。
