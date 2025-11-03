### 概述

默认情况下，niri 会尝试使用所有连接的显示器的首选模式来开启它们。
您可以通过 `output` 配置段来禁用或调整此行为。

完整参数示例如下：

```kdl
output "eDP-1" {
    // off
    mode "1920x1080@120.030"
    scale 2.0
    transform "90"
    position x=1280 y=0
    variable-refresh-rate // on-demand=true
    focus-at-startup
    backdrop-color "#001100"

    hot-corners {
        // off
        top-left
        // top-right
        // bottom-left
        // bottom-right
    }

    layout {
        // ...eDP-1 的布局设置...
    }

    // 自定义模式。注意：可能会损坏您的显示器。
    // mode custom=true "1920x1080@100"
    // modeline 173.00  1920 2048 2248 2576  1080 1083 1088 1120 "-hsync" "+vsync"
}

output "HDMI-A-1" {
    // ...HDMI-A-1 的设置...
}

output "Some Company CoolMonitor 1234" {
    // ...CoolMonitor 的设置...
}
```

输出设备可通过连接器名称（如 `eDP-1`、`HDMI-A-1`）或通过显示器制造商、型号和序列号（各项间以单个空格分隔）进行匹配。
您可以通过运行 `niri msg outputs` 查看所有这些信息。

通常来说，笔记本电脑的内置显示器名称为 `eDP-1`。

<sup>Since: 0.1.6</sup> 输出名称不区分大小写。

<sup>Since: 0.1.9</sup> 输出设备可通过制造商、型号和序列号匹配。
此前仅能通过连接器名称匹配。

### 关闭 `off`

此参数会完全关闭该输出。

```kdl
// 关闭该显示器。
output "HDMI-A-1" {
    off
}
```

### 模式 `mode`

设置显示器的分辨率和刷新率。

格式为 `<宽度>x<高度>` 或 `<宽度>x<高度>@<刷新率>`。
如果省略刷新率，niri 将为该分辨率选择最高的刷新率。

若完全省略模式或设置的模式无效，niri 将尝试自动选择。

在 niri 实例中运行 `niri msg outputs` 可列出所有输出及其模式。
您在此处设置的刷新率必须与您在 `niri msg outputs` 中看到的*完全*匹配，精确到小数点后三位。

```kdl
// 为此显示器设置高刷新率。
// 高刷显示器倾向于使用 60 Hz 作为其首选模式，
// 因此需要手动设置模式。
output "HDMI-A-1" {
    mode "2560x1440@143.912"
}

// 在笔记本电脑的内置显示器上使用较低分辨率
//（例如，用于测试目的）。
output "eDP-1" {
    mode "1280x720"
}
```

#### `mode custom=true`

<sup>Since: next release</sup>

您可以通过设置 `custom=true` 来配置一个自定义模式（非显示器提供的模式）。
在这种情况下，刷新率是必填项。

> [!CAUTION]
> 自定义模式可能会损坏您的显示器，尤其是 CRT 显示器。
> 请遵循显示器说明书中的最大支持限制。

```kdl
// 为该显示器使用自定义模式。
output "HDMI-A-1" {
    mode custom=true "2560x1440@143.912"
}
```

### `modeline`

<sup>Since: next release</sup>

通过 modeline 直接配置显示器的模式，这将覆盖任何已配置的 `mode`。
Modeline 可以通过诸如 [cvt](https://man.archlinux.org/man/cvt.1.en) 或 [gtf](https://man.archlinux.org/man/gtf.1.en) 之类的工具计算。

> [!CAUTION]
> 超出规范的 modeline 可能会损坏您的显示器，尤其是 CRT 显示器。
> 请遵循显示器说明书中的最大支持限制。

```kdl
// 为该显示器使用 modeline 模式。
output "eDP-3" {
    modeline 173.00  1920 2048 2248 2576  1080 1083 1088 1120 "-hsync" "+vsync"
}
```

### 缩放 `scale`

设置显示器的缩放比例。

<sup>Since: 0.1.6</sup> 如果未设置缩放比例，niri 将根据显示器的物理尺寸和分辨率推测一个合适的缩放比例。

<sup>Since: 0.1.7</sup> 您可以使用小数缩放值，例如用 `scale 1.5` 表示 150% 缩放。

<sup>Since: 0.1.7</sup> 整数缩放不再需要小数点，例如您可以写 `scale 2` 而不是 `scale 2.0`。

<sup>Since: 0.1.7</sup> 低于 0 或高于 10 的缩放比例现在会在配置解析时报错。无论如何，缩放比例先前就已被限制在此范围内。

```kdl
output "eDP-1" {
    scale 2.0
}
```

### 旋转 `transform`

逆时针旋转输出。

有效值为：`"normal"`、`"90"`、`"180"`、`"270"`、`"flipped"`、`"flipped-90"`、`"flipped-180"` 和 `"flipped-270"`。
带有 `flipped` 的值会额外对输出进行镜像翻转。

```kdl
output "HDMI-A-1" {
    transform "90"
}
```

### 位置 `position`

设置在全局坐标空间中的输出位置。

此设置会影响定向显示器操作，如 `focus-monitor-left` 和光标移动。
光标只能在直接相邻的输出之间移动。

> [!NOTE]
> 定位时必须考虑输出的缩放和旋转：输出的尺寸是以逻辑像素或缩放后的像素为单位计算的。
> 例如，一个 3840×2160 分辨率、缩放比例为 2.0 的输出，其逻辑尺寸为 1920×1080。因此，若要将另一输出直接置于其右侧，需将其 x 坐标设为 1920。
> 如果位置未设置或导致重叠，则输出会自动放置。

```kdl
output "HDMI-A-1" {
    position x=1280 y=0
}
```

#### 自动定位

每当输出配置发生变化时（包括显示器断开和连接），niri 都会从头重新定位输出。
定位算法如下。

1. 收集所有连接的显示器及其逻辑尺寸。
1. 按名称对它们进行排序。这能确保自动定位不依赖于显示器连接顺序。这一点很重要，因为合成器启动时的连接顺序是不确定的。
1. 尝试按顺序放置每个显式配置了 `position` 的输出。若该输出与已放置的输出重叠，则将其置于所有已放置输出的右侧。在这种情况下，niri 还会打印警告。
1. 将每个未显式配置 `position` 的输出置于所有已放置输出的右侧。

### VRR 可变刷新率 `variable-refresh-rate`

<sup>Since: 0.1.5</sup>

如果输出支持，此参数将启用可变刷新率（VRR，也称为自适应同步、FreeSync 或 G-Sync）。

您可以在 `niri msg outputs` 中检查输出是否支持 VRR。

> [!NOTE]
> 部分驱动程序在 VRR 方面存在各种问题。
>
> 若启用 VRR 后光标移动帧率较低，请尝试设置 [`disable-cursor-plane` 调试参数](./Configuration:-Debug-Options.md#disable-cursor-plane) 并重新连接显示器。
>
> 若显示器本应支持 VRR 但未被检测到，有时拔掉其他显示器可修复此问题。
>
> 部分显示器在启用 VRR 后会持续进行模式设置（黑屏闪烁）；我尚不确定是否有修复方法。

```kdl
output "HDMI-A-1" {
    variable-refresh-rate
}
```

<sup>Since: 0.1.9</sup> 您还可以设置 `on-demand=true` 属性，这将仅当此路输出显示与 `variable-refresh-rate` 窗口规则匹配的窗口时，才启用 VRR。
这有助于避免 VRR 的各种问题，因为它可以在大多数时间都可以禁用，仅在针对特定窗口（如游戏或视频播放器）启用。

```kdl
output "HDMI-A-1" {
    variable-refresh-rate on-demand=true
}
```

### 启动时聚焦 `focus-at-startup`

<sup>Since: 25.05</sup>

niri 启动时默认聚焦到此输出。

如果连接了多个带有 `focus-at-startup` 的输出，则按它们在配置中出现的顺序确定优先级。
当没有已连接的输出被显式设置为 `focus-at-startup` 时，niri 将聚焦按名称排序的第一个输出（与 niri 在其他地方使用的输出排序相同）。

```kdl
// 默认聚焦 HDMI-A-1。
output "HDMI-A-1" {
    focus-at-startup
}

// ...如果 HDMI-A-1 未连接，则改为聚焦 DP-2。
output "DP-2" {
    focus-at-startup
}
```

### 背景颜色 `background-color`

<sup>Since: 0.1.8</sup>

设置 niri 为此输出上的工作区绘制的背景颜色。
当您未使用任何背景工具（如 swaybg）时，此颜色可见。

<sup>Until: 25.05</sup> 此颜色的 alpha 通道将会被忽略。

<sup>Since: next release</sup> 此设置已弃用，请在 [输出 `layout {}` 配置段](#layout-config-overrides) 中设置 `background-color`。

```kdl
output "HDMI-A-1" {
    background-color "#003300"
}
```

### 幕布颜色 `backdrop-color`

<sup>Since: 25.05</sup>

设置 niri 为此输出绘制的背景颜色。
这在工作区之间或桌面概览中是可见的。

此颜色的 alpha 通道将会被忽略。

```kdl
output "HDMI-A-1" {
    backdrop-color "#001100"
}
```

### 热区 `hot-corners`

<sup>Since: next release</sup>

为此输出自定义热区。
默认情况下，[手势设置中的](./Configuration:-Gestures.md#hot-corners) 热区适用于所有输出。

当您将鼠标置于显示器角落时，热区会切换桌面概览。

`off` 将禁用此输出上的热区，而指定具体角落则仅在此输出上启用那些角落上的热区。

```kdl
// 在 HDMI-A-1 上启用左下角和右下角热区。
output "HDMI-A-1" {
    hot-corners {
        bottom-left
        bottom-right
    }
}

// 禁用 DP-2 上的热区。
output "DP-2" {
    hot-corners {
        off
    }
}
```

### 布局配置覆写 {#layout-config-overrides}

<sup>Since: next release</sup>

您可以使用 `layout {}` 配置段为输出自定义布局设置：

```kdl
output "SomeCompany VerticalMonitor 1234" {
    transform "90"

    // 仅针对此输出的布局配置覆写。
    layout {
        default-column-width { proportion 1.0; }

        // ...任何其他设置。
    }
}

output "SomeCompany UltrawideMonitor 1234" {
    // 超宽屏使用更窄的比例和更多预设。
    layout {
        default-column-width { proportion 0.25; }

        preset-column-widths {
            proportion 0.2
            proportion 0.25
            proportion 0.5
            proportion 0.75
            proportion 0.8
        }
    }
}
```

它接受与[顶部 `layout {}` 配置段](./Configuration:-Layout.md)相同的所有选项。

要取消设置某个参数，请使用 `false` 写入它，例如：

```kdl
layout {
    // 全局启用。
    always-center-single-column
}

output "eDP-1" {
    layout {
        // 在此输出上取消设置。
        always-center-single-column false
    }
}
```
