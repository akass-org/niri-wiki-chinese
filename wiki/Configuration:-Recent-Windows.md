### 概览

<sup>Since: next release</sup>

在本节中，您可以配置最近窗口切换器（Alt-Tab）。

以下是可用设置及其默认值的概览：

```kdl
recent-windows {
    // off
    open-delay-ms 150

    highlight {
        active-color "#999999ff"
        urgent-color "#ff9999ff"
        padding 30
        corner-radius 0
    }

    previews {
        max-height 480
        max-scale 0.5
    }

    binds {
        Alt+Tab         { next-window; }
        Alt+Shift+Tab   { previous-window; }
        Alt+grave       { next-window     filter="app-id"; }
        Alt+Shift+grave { previous-window filter="app-id"; }

        Mod+Tab         { next-window; }
        Mod+Shift+Tab   { previous-window; }
        Mod+grave       { next-window     filter="app-id"; }
        Mod+Shift+grave { previous-window filter="app-id"; }
    }
}
```

`off` 会完全禁用最近窗口切换器。

### `open-delay-ms`

从按下 Alt-Tab 绑定到最近窗口切换器在屏幕上显示之间的延迟，以毫秒为单位。

默认情况下切换器会延迟显示，这样在快速轻按 Alt-Tab 切换窗口时，不会引起令人厌烦的全屏视觉变化。

```kdl
recent-windows {
    // 让切换器立即出现。
    open-delay-ms 0
}
```

### `highlight`

控制最近窗口切换器中聚焦窗口预览背后的高亮效果。

- `active-color`：聚焦窗口高亮的正常颜色。
- `urgent-color`：紧急聚焦窗口高亮的颜色，在未聚焦窗口上会以较深的色调显示。
- `padding`：高亮在窗口预览周围的内边距，以逻辑像素为单位。
- `corner-radius`：高亮的圆角半径。

```kdl
recent-windows {
    // 让高亮具有圆角。
    highlight {
        corner-radius 14
    }
}
```

### `previews`

控制切换器中的窗口预览。

- `max-scale`：窗口预览的最大缩放比例。
窗口无法被缩放到比此值更大。
- `max-height`：窗口预览的最大高度。
进一步限制预览大小，以便在大型显示器上占用更少的空间。

在较小的显示器上，预览尺寸主要受 `max-scale` 限制；在较大的显示器上，则主要受 `max-height` 限制。

`max-scale` 限制会应用两次：作用于最终的窗口缩放比例，以及窗口高度（不能超过 `显示器高度 × 最大缩放比例`）。

```kdl
recent-windows {
    // 缩小预览以在屏幕上容纳更多窗口。
    previews {
        max-height 320
    }
}
```

```kdl
recent-windows {
    // 放大预览以便查看窗口内容。
    previews {
        max-height 1080
        max-scale 0.75
    }
}
```

### `binds`

配置用于打开和导航最近窗口切换器的绑定。

默认用于在所有窗口间切换的绑定为 <kbd>Alt</kbd><kbd>Tab</kbd> / <kbd>Mod</kbd><kbd>Tab</kbd>,用于在当前应用的窗口间切换的绑定为 <kbd>Alt</kbd><kbd>\`</kbd> / <kbd>Mod</kbd><kbd>\`</kbd> 。
添加 <kbd>Shift</kbd> 将反向切换窗口。

在配置中添加 `binds {}` 配置段会移除所有默认绑定。
您可以从本 wiki 页面顶部的概览中复制所需的绑定。

```kdl
recent-windows {
    // 即使是空的 binds {} 节也会移除所有默认绑定。
    binds {
    }
}
```

可用的操作是 `next-window` 和 `previous-window`。
它们可以选择性地拥有以下属性：

- `filter="app-id"`：将切换器过滤到当前选中应用的窗口，由 Wayland 应用 ID 确定。
- `scope="all"`、`scope="output"`、`scope="workspace"`：设置使用此绑定打开最近窗口切换器时预选的作用域。

```kdl
recent-windows {
    // 切换窗口时预选「Output」作用域。
    binds {
        Mod+Tab         { next-window     scope="output"; }
        Mod+Shift+Tab   { previous-window scope="output"; }
        Mod+grave       { next-window     scope="output" filter="app-id"; }
        Mod+Shift+grave { previous-window scope="output" filter="app-id"; }
    }
}
```

最近窗口绑定的优先级低于[常规绑定](./Configuration:-Key-Bindings.md)，这意味着如果您在常规绑定中将 <kbd>Alt</kbd><kbd>Tab</kbd> 绑定到了其他操作，`recent-windows` 绑定将无法生效。
在这种情况下，您可以移除冲突的常规绑定。

本节中的所有绑定必须包含修饰键，如 <kbd>Alt</kbd> 或 <kbd>Mod</kbd>，因为最近窗口切换器仅在按住任意修饰键时才会保持打开。

#### 切换器内部的绑定

当切换器打开时，可以使用一些硬编码的绑定：

- <kbd>Escape</kbd> 取消切换器。
- <kbd>Enter</kbd> 关闭切换器并确认当前窗口。
- <kbd>A</kbd>、<kbd>W</kbd>、<kbd>O</kbd> 选择特定作用域。
- <kbd>S</kbd> 在作用域之间循环切换，如顶部面板所示。
- <kbd>←</kbd>、<kbd>→</kbd>、<kbd>Home</kbd>、<kbd>End</kbd> 按方向移动选择。

此外，某些常规绑定会在切换器中自动生效：

- focus column left/right 及其变体：将在切换器内向左/向右移动选择。
- focus column first/last：将选择移动到第一个或最后一个窗口。
- close window：将关闭切换器中当前聚焦的窗口。
- screenshot：将打开截图界面。

其工作原理是查找对应于这些操作的所有常规绑定，并仅使用触发键而不带修饰键。
例如，如果您将 <kbd>Mod</kbd><kbd>Shift</kbd><kbd>C</kbd> 绑定到 `close-window`，在窗口切换器中单独按下 <kbd>C</kbd> 键将会关闭窗口。

这样我们就不需要硬编码如 HJKL 方向移动之类的设置。
如果您使用的是 Colemak-DH MNEI 绑定，它们在窗口切换器中同样会生效（只要不与硬编码的绑定冲突）。