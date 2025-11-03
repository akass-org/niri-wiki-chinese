在 niri 中有几种方式可以放大窗口：最大化列、将窗口最大化到边缘以及全屏显示窗口。
让我们来看看它们之间的区别。

## 最大化（全宽）列

通过 `maximize-column`（默认绑定到 <kbd>Mod</kbd><kbd>F</kbd>）最大化列会将其宽度扩展到覆盖整个屏幕。
最大化的列仍然会为 [struts] 和 [gaps] 留出空间，并且可以包含多个窗口。
窗口会保留其边框。
这是最简单的调整尺寸的模式，等同于 `proportion 1.0` 的列宽度，或 `set-column-width "100%"`。

![包含两个窗口的最大化列的截图。](./img/maximized-column.png)

你可以使用 [`open-maximized true`](./Configuration:-Window-Rules.md#open-maximized) 窗口规则让窗口在最大化的列中打开。

## 最大化到边缘的窗口

<sup>Since: next release</sup>

你可以通过 `maximize-window-to-edges` 最大化单个窗口。
这与你在其他桌面环境和操作系统中可以找到的最大化功能相同：它会将一个窗口扩展到可用屏幕区域的边缘。
你仍然可以看到你的任务栏，但不会看到 struts、间隙或边框。

窗口能感知到它们被最大化到边缘的状态，并通常会通过将边角变为直角来响应。
窗口也可以控制最大化到边缘：当你点击窗口标题栏上的方形图标，或双击标题栏时，窗口会请求 niri 将其最大化或取消最大化。

你可以将多个最大化的窗口放入一个 [标签页列](./Tabs.md) 中，但不能放入常规列中。

![一个最大化到边缘的窗口的截图。](./img/window-maximized-to-edges.png)

你可以使用 [`open-maximized-to-edges`](./Configuration:-Window-Rules.md#open-maximized-to-edges) 窗口规则让窗口在打开时即以最大化到边缘的方式打开，或阻止窗口在打开时最大化。

## 全屏窗口

窗口可以进入全屏模式，这通常见于视频播放器、演示文稿或游戏。
你也可以通过 `fullscreen-window`（默认绑定到 <kbd>Mod</kbd><kbd>Shift</kbd><kbd>F</kbd>）强制窗口进入全屏模式。
全屏窗口会覆盖整个屏幕。
与最大化到边缘类似，窗口能感知到它们的全屏状态，并可以通过隐藏其标题栏或用户界面的其他部分来响应。

Niri 会在全屏窗口后面渲染一个纯黑色背景。
当窗口本身仍然过小（例如，如果你尝试将一个固定大小的对话框窗口全屏）时，这个背景有助于匹配屏幕尺寸，这是 [由 Wayland 协议定义的行为](https://wayland.app/protocols/xdg-shell#xdg_toplevel:request:set_fullscreen)。

当一个全屏窗口获得焦点且没有在进行动画时，它会覆盖浮动窗口和顶部的 layer-shell 层。
例如，如果你希望你的 layer-shell 通知或启动器能够显示在全屏窗口之上，请将配置相应的工具，将它们置于覆盖层 layer-shell 层上。

![一个全屏窗口的截图。](./img/fullscreen-window.png)

你可以使用 [`open-fullscreen`](./Configuration:-Window-Rules.md#open-fullscreen) 窗口规则让窗口在打开时即全屏，或阻止窗口在打开时全屏。

## 全屏和最大化模式下的通用行为

全屏或最大化到边缘的窗口只能位于滚动布局中。
因此，如果你尝试将一个 [浮动窗口](./Floating-Windows.md) 全屏或最大化，它将移动到滚动布局中。
然后，取消全屏/取消最大化会自动将其带回浮动布局。

得益于可滚动平铺布局，全屏和最大化的窗口仍然是布局的正常参与者：你可以向左或向右滚动来查看其他窗口。

![概览截图，显示一个全屏窗口与其他窗口并排显示。](./img/fullscreen-window-in-overview.png)

全屏和最大化到边缘都是窗口能感知并可以控制的特殊状态。
窗口有时希望在打开时恢复其全屏状态，或者更常见的是最大化状态。
实现这一点的最佳时机是在*初始配置*序列期间，此时窗口会在打开前告知 niri 它应该知道的所有信息。
如果窗口这样做了，那么 `open-maximized-to-edges` 和 `open-fullscreen` 窗口规则就有机会阻止或调整该请求。

然而，有些客户端倾向于在*初始配置序列之后不久*请求最大化，此时 niri 已经向它们发送了初始尺寸请求（有时甚至在屏幕上显示之后，导致打开后立即快速调整大小）。
从 niri 的角度来看，此时窗口已经打开，因此如果窗口这样做，那么 `open-maximized-to-edges` 和 `open-fullscreen` 窗口规则将不起任何作用。

## 窗口化全屏

<sup>Since: 25.05</sup>

Niri 还可以通过 `toggle-windowed-fullscreen` 动作告知窗口它处于全屏状态，而实际上并不使其全屏。
这通常对于屏幕录制基于浏览器的演示文稿非常有用，当你想隐藏浏览器用户界面，但仍希望窗口保持普通窗口的大小时。

在窗口化全屏模式下，你可以使用 niri 动作来最大化或取消最大化窗口。
窗口侧的标题栏最大化按钮和手势可能不起作用，因为窗口会始终认为它处于全屏状态。

另请参阅 [屏幕录制功能 wiki 页面](./Screencasting.md#windowed-fakedetached-fullscreen) 上的窗口化全屏内容。


[struts]: ./Configuration:-Layout.md#struts
[gaps]: ./Configuration:-Layout.md#gaps
