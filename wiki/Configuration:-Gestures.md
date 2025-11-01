### 概述

<sup>Since: 25.02</sup>

`gestures` 配置部分包含手势设置。
有关所有 niri 手势的概述，请参阅 [手势](./Gestures.md) wiki 页面。

以下是可用设置及其默认值的快速概览。

```kdl
gestures {
    dnd-edge-view-scroll {
        trigger-width 30
        delay-ms 100
        max-speed 1500
    }

    dnd-edge-workspace-switch {
        trigger-height 50
        delay-ms 100
        max-speed 1500
    }

    hot-corners {
        // off
        top-left
        // top-right
        // bottom-left
        // bottom-right
    }
}
```

### `dnd-edge-view-scroll`

在拖放（DnD）操作期间，当鼠标光标移动到显示器边缘时滚动平铺视图。
在触摸屏上同样有效。

此功能适用于常规的拖放操作（例如从文件管理器拖动文件），以及针对平铺布局的窗口交互式移动。

选项包括：

- `trigger-width`：靠近显示器边缘时将触发滚动的区域大小，单位为逻辑像素。
- `delay-ms`：滚动开始前的延迟时间，单位为毫秒。
可避免在跨显示器拖动项目时发生意外滚动。
- `max-speed`：最大滚动速度，单位为逻辑像素/秒。
当您将鼠标光标从 `trigger-width` 区域移动到显示器最边缘时，滚动速度会线性增加。

```kdl
gestures {
    // 增加触发区域和最大速度。
    dnd-edge-view-scroll {
        trigger-width 100
        max-speed 3000
    }
}
```

### `dnd-edge-workspace-switch`

<sup>Since: 25.05</sup>

在概览模式下进行拖放（DnD）操作期间，当鼠标光标移动到显示器边缘时向上/向下滚动工作区。
同样适用于触摸屏。

选项包括：

- `trigger-height`：靠近显示器边缘的触发滚动区域的大小，单位为逻辑像素。
- `delay-ms`：滚动开始前的延迟时间，单位为毫秒。
可避免在跨显示器拖动项目时发生意外滚动。
- `max-speed`：最大滚动速度；1500 对应每秒一个屏幕高度。
当您将鼠标光标从 `trigger-width` 区域移动到显示器最边缘时，滚动速度会线性增加。

```kdl
gestures {
    // 增加触发区域和最大速度。
    dnd-edge-workspace-switch {
        trigger-height 100
        max-speed 3000
    }
}
```

### `hot-corners`

<sup>Since: 25.05</sup>

将鼠标置于显示器的左上角可切换全局概览模式。
在拖放操作期间同样有效。

`off` 可禁用热区。

```kdl
// 禁用热区。
gestures {
    hot-corners {
        off
    }
}
```

<sup>Since: next release</sup> 您可以通过名称选择特定的热区：`top-left`、`top-right`、`bottom-left`、`bottom-right`。
如果未明确设置任何角，则默认激活左上角。

```kdl
// 启用右上角和右下角热区。
gestures {
    hot-corners {
        top-right
        bottom-right
    }
}
```

您还可以在[输出配置](./Configuration:-Outputs.md#hot-corners)中为每个输出自定义热区。
