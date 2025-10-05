### 概述

<sup>Since: 25.02</sup>

您可以将列（column）中的窗口切换为标签页形式显示，替代原有的垂直平铺布局。
同一列中所有标签页的窗口尺寸完全一致，这一特性尤其有利于获得更多垂直空间。

![左侧带有标签指示符的终端。](https://github.com/user-attachments/assets/0e94ac0d-796d-4f85-a264-c105ef41c13f)

可以使用以下快捷键绑定在常规显示模式和标签页显示模式之间切换l列布局：

```kdl
binds {
   Mod+W { toggle-column-tabbed-display; }
}
```

所有其他快捷键绑定保持不变：使用 `focus-window-down/up` 切换标签页，使用 `consume-window-into-column`/`expel-window-from-column` 添加或移除窗口，等等。

与常规列不同，标签页列可以全屏显示多个窗口。

### 标签指示器

标签页列在侧面显示一个标签指示器。
您可以点击指示器来切换标签页。

有关配置，请参见[布局部分中的 `tab-indicator` 小节](./Configuration:-Layout.md#tab-indicator)。

默认情况下，指示器会绘制在列的"外部"，因此可能会叠加在其他窗口上或超出屏幕范围。
启用 `place-within-column` 标志后，指示器将置于列的"内部"，系统会调整窗口大小以为其留出空间。
这一特性对于较厚的标签指示器或间隙极小的布局尤为实用。

| 默认 | `place-within-column` |
| --- | --- |
| ![截图显示4个窗口，中间列处于聚焦状态。标签指示器溢出到左侧列](https://github.com/user-attachments/assets/c2f51f50-3d87-403a-8beb-cbbe5ec5c880) | ![截图显示4个窗口，中间列处于聚焦状态。标签指示器包含在其各自的列内](https://github.com/user-attachments/assets/f1797cd0-d518-4be6-95b4-3540523c4370) |
