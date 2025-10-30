### 概述

Niri 提供了多种可配置的动画效果，这些动画采用统一的配置方式。
此外，您还可以一次性禁用所有动画或降低所有动画速度。

以下是可用动画及其默认值的快速概览。

```kdl
animations {
    // 取消注释以关闭所有动画。
    // 你也可以在单个动画中设置 "off" 来禁用它。
    // off

    // 按此系数减慢所有动画速度。低于 1 的值会加快动画速度。
    // slowdown 3.0

    // 单个动画配置。

    workspace-switch {
        spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
    }

    window-open {
        duration-ms 150
        curve "ease-out-expo"
    }

    window-close {
        duration-ms 150
        curve "ease-out-quad"
    }

    horizontal-view-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
    }

    window-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
    }

    window-resize {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
    }

    config-notification-open-close {
        spring damping-ratio=0.6 stiffness=1000 epsilon=0.001
    }

    exit-confirmation-open-close {
        spring damping-ratio=0.6 stiffness=500 epsilon=0.01
    }

    screenshot-ui-open {
        duration-ms 200
        curve "ease-out-quad"
    }

    overview-open-close {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
    }
}
```

### 动画类型

有两种动画类型：easing（缓动）和 spring（弹簧）。
每个动画都可以配置为缓动或弹簧效果。

#### 缓动动画

这是一种相对常见的动画类型，它使用插值曲线在设定的持续时间内改变数值。

要使用此动画，请设置以下参数：

- `duration-ms`：动画的持续时间，以毫秒为单位。
- `curve`：要使用的缓动曲线。

```kdl
animations {
    window-open {
        duration-ms 150
        curve "ease-out-expo"
    }
}
```

目前，niri 仅支持五种曲线。
你可以在 [easings.net](https://easings.net/) 这样的网页上感受它们的效果。

- `ease-out-quad` <sup>Since: 0.1.5</sup>
- `ease-out-cubic`
- `ease-out-expo`
- `linear` <sup>Since: 0.1.6</sup>
- `cubic-bezier` <sup>Since: 25.08</sup>
    一个自定义的[三次贝塞尔曲线](https://www.w3.org/TR/css-easing-1/#cubic-bezier-easing-functions)。你需要设置 4 个数字来定义曲线的控制点，例如：
    ```kdl
    animations {
        window-open {
            // 等同于 CSS cubic-bezier(0.05, 0.7, 0.1, 1)
            curve "cubic-bezier" 0.05 0.7 0.1 1
        }
    }
    ```
    你可以在 [easings.co](https://easings.co?curve=0.05,0.7,0.1,1) 这样的网页上调整 cubic-bezier 参数。

#### 弹簧动画

弹簧动画使用物理弹簧模型来驱动数值变化。
在触摸板手势操作中，它的体验感会显著提升，因为动画会捕捉到你松开手指时的速度。
如果你喜欢，可以通过设置合适的参数让动画在末尾产生振荡或回弹效果，但这并非必须（默认情况下基本不会启用）。

由于弹簧动画基于物理模型，其参数不那么直观，通常需要通过反复测试来进行调整。
值得注意的是，你无法直接设置动画的持续时间。
你可以使用 [Elastic](https://flathub.org/apps/app.drey.Elastic) 应用来帮助可视化弹簧参数对动画的影响。

弹簧动画的配置如下，包含三个必需参数：

```kdl
animations {
    workspace-switch {
        spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
    }
}
```

`damping-ratio` 的取值范围是 0.1 到 10.0，其特性如下：

- 低于 1.0：欠阻尼弹簧，最终会产生振荡。
- 高于 1.0：过阻尼弹簧，不会产生振荡。
- 1.0：临界阻尼弹簧，能在不产生振荡的前提下，以最短时间恢复静止。

然而，即使阻尼比设置为 1.0，如果通过触摸板滑动赋予了动画足够大的“初始”速度，动画仍可能产生振荡。

> [!WARNING]
> 过阻尼弹簧目前存在一些数值稳定性问题，可能会导致图形错误。
> 因此，不建议将 `damping-ratio` 设置得高于 `1.0`。

较低的 `stiffness`（刚度）会导致动画变慢，并且更容易产生振荡。

如果动画在末尾出现“跳跃”，请将 `epsilon` 设置为更低的值。

> [!TIP]
> 弹簧的*质量*（你可以在 Elastic 中看到）被硬编码为 1.0，无法更改。
> 请改为按比例更改 `stiffness`。
> 例如，将质量增加 2 倍与将刚度减小 2 倍的效果相同。

### 动画

现在让我们更详细地介绍你可以配置的动画。

#### `workspace-switch`

上下切换工作区时的动画，包括垂直触摸板手势之后（推荐使用弹簧）。

```kdl
animations {
    workspace-switch {
        spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
    }
}
```

#### `window-open`

窗口打开动画。

此动画默认使用缓动类型。

```kdl
animations {
    window-open {
        duration-ms 150
        curve "ease-out-expo"
    }
}
```

##### `custom-shader`

<sup>Since: 0.1.6</sup>

你可以编写一个自定义着色器，在打开动画期间绘制窗口。

请参阅[此示例着色器](./examples/open_custom_shader.frag)获取完整文档，其中包含多个可供试验的动画效果。

如果自定义着色器编译失败，niri 将打印警告并回退到默认或先前成功编译的着色器。
当 niri 作为 systemd 服务运行时，你可以在日志中看到警告：`journalctl -ef /usr/bin/niri`

> [!WARNING]
>
> 自定义着色器不保证向后兼容。
> 我在开发新功能时，可能会更改它们的接口。

示例：打开时将用纯色渐变填充当前几何区域，并逐渐淡入。

```kdl
animations {
    window-open {
        duration-ms 250
        curve "linear"

        custom-shader r"
            vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                vec4 color = vec4(0.0);

                if (0.0 <= coords_geo.x && coords_geo.x <= 1.0
                        && 0.0 <= coords_geo.y && coords_geo.y <= 1.0)
                {
                    vec4 from = vec4(1.0, 0.0, 0.0, 1.0);
                    vec4 to = vec4(0.0, 1.0, 0.0, 1.0);
                    color = mix(from, to, coords_geo.y);
                }

                return color * niri_clamped_progress;
            }
        "
    }
}
```

#### `window-close`

<sup>Since: 0.1.5</sup>

窗口关闭动画。

此动画默认使用缓动类型。

```kdl
animations {
    window-close {
        duration-ms 150
        curve "ease-out-quad"
    }
}
```

##### `custom-shader`

<sup>Since: 0.1.6</sup>

你可以编写一个自定义着色器，在关闭动画期间绘制窗口。

请参阅[此示例着色器](./examples/close_custom_shader.frag)获取完整文档，其中包含多个可供试验的动画效果。

如果自定义着色器编译失败，niri 将打印警告并回退到默认或先前成功编译的着色器。
当 niri 作为 systemd 服务运行时，你可以在日志中看到警告：`journalctl -ef /usr/bin/niri`

> [!WARNING]
>
> 自定义着色器不保证向后兼容。
> 我在开发新功能时，可能会更改它们的接口。

示例：关闭时将用纯色渐变填充当前几何形状，并逐渐淡出。

```kdl
animations {
    window-close {
        custom-shader r"
            vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                vec4 color = vec4(0.0);

                if (0.0 <= coords_geo.x && coords_geo.x <= 1.0
                        && 0.0 <= coords_geo.y && coords_geo.y <= 1.0)
                {
                    vec4 from = vec4(1.0, 0.0, 0.0, 1.0);
                    vec4 to = vec4(0.0, 1.0, 0.0, 1.0);
                    color = mix(from, to, coords_geo.y);
                }

                return color * (1.0 - niri_clamped_progress);
            }
        "
    }
}
```

#### `horizontal-view-movement`

所有水平摄像机视角移动动画，例如：

- 当一个屏幕外的窗口被聚焦，相机随之滚动到该窗口时。
- 当一个新窗口出现在屏幕外，相机随之滚动到该窗口时。
- 在执行水平触摸板手势之后（推荐使用弹簧动画）。

```kdl
animations {
    horizontal-view-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
    }
}
```

#### `window-movement`

<sup>Since: 0.1.5</sup>

工作区内单个窗口的移动。

包括：

- 使用 `move-column-left` 和 `move-column-right` 移动窗口列。
- 使用 `move-window-up` 和 `move-window-down` 在同一列内移动窗口。
- 在窗口打开或关闭时，移动其他窗口以腾出空间。
- 在执行销毁或弹出操作时，窗口在列之间的移动。

此动画*不包括*摄像机视角移动，例如左右滚动工作区。

```kdl
animations {
    window-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
    }
}
```

#### `window-resize`

<sup>Since: 0.1.5</sup>

窗口大小调整动画。

只有手动调整窗口大小时才会有动画，即当你使用 `switch-preset-column-width` 或 `maximize-column` 调整窗口大小时。
此外，非常小的调整（直到 10 像素）都没有动画。

```kdl
animations {
    window-resize {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
    }
}
```

##### `custom-shader`

<sup>Since: 0.1.6</sup>

你可以编写一个自定义着色器，在调整大小动画期间绘制窗口。

请参阅[此示例着色器](./examples/resize_custom_shader.frag)获取完整文档，其中包含多个可供试验的动画效果。

如果自定义着色器编译失败，niri 将打印警告并回退到默认或先前成功编译的着色器。
当 niri 作为 systemd 服务运行时，你可以在日志中看到警告：`journalctl -ef /usr/bin/niri`

> [!WARNING]
>
> 自定义着色器不保证向后兼容。
> 我在开发新功能时，可能会更改它们的接口。

示例：调整大小时将立即显示下一个（调整大小后）的窗口纹理，并拉伸到当前几何区域。

```kdl
animations {
    window-resize {
        custom-shader r"
            vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
                vec3 coords_tex_next = niri_geo_to_tex_next * coords_curr_geo;
                vec4 color = texture2D(niri_tex_next, coords_tex_next.st);
                return color;
            }
        "
    }
}
```

#### `config-notification-open-close`

配置解析错误和新的默认配置通知的打开/关闭动画。

此动画默认使用欠阻尼弹簧（`damping-ratio=0.6`），这会在动画末尾引起轻微振荡。

```kdl
animations {
    config-notification-open-close {
        spring damping-ratio=0.6 stiffness=1000 epsilon=0.001
    }
}
```

#### `exit-confirmation-open-close`

<sup>Since: 25.08</sup>

退出确认对话框的打开/关闭动画。

此动画默认使用欠阻尼弹簧（`damping-ratio=0.6`），这会在动画末尾引起轻微振荡。

```kdl
animations {
    exit-confirmation-open-close {
        spring damping-ratio=0.6 stiffness=500 epsilon=0.01
    }
}
```

#### `screenshot-ui-open`

<sup>Since: 0.1.8</sup>

截图用户界面的打开（淡入）动画。

```kdl
animations {
    screenshot-ui-open {
        duration-ms 200
        curve "ease-out-quad"
    }
}
```

#### `overview-open-close`

<sup>Since: 25.05</sup>

[全局概览](./Overview.md)的打开/关闭缩放动画。

```kdl
animations {
    overview-open-close {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
    }
}
```

### 同步动画

<sup>Since: 0.1.5</sup>

有时，当两个动画需要同步播放时，niri 将使用相同的配置来驱动它们。

例如，如果调整窗口大小导致视角移动，那么该视角移动动画也将使用 `window-resize` 配置（而不是 `horizontal-view-movement` 配置）。
这对于在使用 `center-focused-column "always"` 时让动画调整大小看起来流畅尤为重要。

再举一个例子，在列中垂直调整窗口大小时，会导致其他窗口向上或向下移动到新位置。
此移动将使用 `window-resize` 配置，而不是 `window-movement` 配置，以保持动画同步。

有少数操作仍然缺少此同步逻辑，因为在某些情况下难以正确实现。
因此，为获得最佳效果，请考虑为相关动画使用相同的参数（默认情况下它们都是相同的）：

- `horizontal-view-movement`
- `window-movement`
- `window-resize`
