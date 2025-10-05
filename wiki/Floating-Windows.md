### 概述

<sup>Since: 25.01</sup>

在 niri 中，浮动窗口始终显示在平铺窗口的上方。
浮动布局不支持滚动操作。
每个工作区/显示器都有其独立的浮动布局，这与每个工作区/显示器拥有独立平铺布局的特性一致。

满足以下条件的新窗口将自动启用浮动模式：若存在父窗口（如对话框），或窗口尺寸固定（如启动画面）。
要切换窗口的浮动和平铺状态，可通过快捷键绑定 `toggle-window-floating`实现，或在拖拽窗口时右键单击。
您也可以使用 `open-floating true/false` 窗口规则来强制窗口以浮动状态打开，或禁用自动浮动逻辑。

使用 `switch-focus-between-floating-and-tiling` 可在两种布局之间切换焦点。
当焦点在浮动布局上时，快捷键操作（如 `focus-column-right`）将作用于浮动窗口。

您可以使用类似 `niri msg action move-floating-window -x 100 -y 200` 的命令来实现浮动窗口的精确定位。
