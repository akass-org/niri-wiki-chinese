### 概述

<sup>Since: 25.05</sup>

全局概览（Overview）是以缩略视图形式展示工作区与窗口的界面。
它让您能纵览全局状态、快速导航，并通过拖拽操作调整窗口布局。

<video controls src="https://github.com/user-attachments/assets/379a5d1f-acdb-4c11-b36c-e85fd91f0995">

https://github.com/user-attachments/assets/379a5d1f-acdb-4c11-b36c-e85fd91f0995

</video>

您可通过以下方式开启：使用 toggle-overview 快捷键、触发左上角热区，或在触控板上执行四指上滑手势。
在全局概览模式下，所有键盘快捷键仍可正常使用，而指针设备的操作则更为便捷：

- 鼠标：左键单击可以拖拽窗口来移动他们，右键单击并拖动可以横向移动工作区，滚轮切换工作区（无需按住 Mod 键）。
- 触摸板：双指滚动操作，与常规三指手势逻辑一致。
- 触摸屏：单指滚动浏览，或者单指长按来拖拽窗口。

> [!TIP]
> 概览需要在每个工作区下方绘制背景。
> 因此，layer-shell 界面的运作机制是这样的：*背景（background）* 和 *底部（bottom）* 层会随工作区同步缩放，而 *顶部（top）* 和 *覆盖（overlay）* 层则始终保持在全局概览界面的最顶层。
>
> 将您的状态栏放在 *顶部* 层级。

在全局概览中执行拖放操作时，工作区会进行垂直滚动；若将元素悬停片刻，系统将自动激活对应工作区。
结合热区功能，可实现纯鼠标操作的跨工作区拖放流程。

<video controls src="https://github.com/user-attachments/assets/5f09c5b7-ff40-462b-8b9c-f1b8073a2cbb">

https://github.com/user-attachments/assets/5f09c5b7-ff40-462b-8b9c-f1b8073a2cbb

</video>

您还可以将窗口拖放到现有工作区的上方、下方或间隙位置，来创建新的工作区。

<video controls src="https://github.com/user-attachments/assets/b76d5349-aa20-4889-ab90-0a51554c789d">

https://github.com/user-attachments/assets/b76d5349-aa20-4889-ab90-0a51554c789d

</video>

### 配置

有关 `overview {}` 部分的完整文档，请参见[此处](./Configuration:-Miscellaneous.md#overview)。

您可以像这样设置缩放级别：

```kdl
// 在全局概览中使工作区大小为正常的四分之一。
overview {
    zoom 0.25
}
```

要更改工作区后面的颜色，请使用 `backdrop-color` 设置：

```kdl
// 使背景变浅。
overview {
    backdrop-color "#777777"
}
```

您也可以禁用热区：

```kdl
// 禁用热区。
gestures {
    hot-corners {
        off
    }
}
```

### 自定义背景

除了上文提及的自定义背景颜色设置之外，您还可以通过 [layer-shell 规则](./Configuration:-Layer-Rules.md#place-within-backdrop)将 layer-shell 壁纸置于底层背景，例如：

```kdl
// 将 swaybg 放入概览背景中。
layer-rule {
    match namespace="^wallpaper$"
    place-within-backdrop true
}
```

该功能仅对忽略独占区域的 background 图层界面生效（常见于壁纸工具）。

您可以运行两个不同的壁纸工具（如 swaybg 和 swww），分别用于底层背景和常规工作区背景。
通过这种方式，您可以将底层背景设置为壁纸的模糊版本，实现良好的视觉效果。

如果您不喜欢壁纸随工作区一起移动，也可以将其与透明背景颜色结合使用：

```kdl
// 使壁纸保持静止，而不是随工作区移动。
layer-rule {
    // 这是针对 swaybg 的；其他壁纸工具请相应更改。
    // 通过运行 niri msg layers 找到正确的命名空间。
    match namespace="^wallpaper$"
    place-within-backdrop true
}

// 设置透明的工作区背景颜色。
layout {
    background-color "transparent"
}

// 可选，禁用概览中的工作区阴影。
overview {
    workspace-shadow {
        off
    }
}
```
