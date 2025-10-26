### 概述

<sup>Since: 0.1.6</sup>

您可以在配置的顶部声明命名工作区：

```kdl
workspace "browser"

workspace "chat" {
    open-on-output "Some Company CoolMonitor 1234"
}
```

与普通的动态工作区相反，命名工作区始终存在，即使它们没有任何窗口。
除此之外，它们的行为与其他普通工作区一样：您可以移动它们改变顺序、将它们拖到其他显示器，等等。

诸如 `focus-workspace` 或 `move-column-to-workspace` 之类的操作都可以用名称来指代工作区。
此外，您可以使用 `open-on-workspace` 窗口规则来让窗口在特定的命名工作区中打开：

```kdl
// 声明一个名为 chat 的工作区，它会在 DP-2 输出上打开。
workspace "chat" {
    open-on-output "DP-2"
}

// 如果 Fractal 在 niri 启动时运行，则在 chat 工作区上打开它。
window-rule {
    match at-startup=true app-id=r#"^org\.gnome\.Fractal$"#
    open-on-workspace "chat"
}
```

命名工作区进行初始化的顺序与它们在配置文件中声明的顺序一致。
若在 niri 运行时修改配置，则新增的命名工作区将出现在显示器的最顶端。

如果您从配置中删除了某个命名工作区，该工作区将退化成普通（无命名）工作区；如果该工作区上没有窗口，则会像普通空工作区一样被自动销毁。
无法为已存在的工作区补充命名，但您可以直接将想要的窗口移动到一个新的、空的命名工作区。

<sup>Since: 0.1.9</sup> `open-on-output` 现在可以使用显示器的制造商、型号和序列号。
在此之前，它只能使用连接器名称。

<sup>Since: 25.01</sup> 您可以使用 `set-workspace-name` 和 `unset-workspace-name` 动作来动态更改工作区名称。

<sup>Since: 25.02</sup> 命名工作区不再因为在其上打开新窗口而更新/遗忘原始输出（无命名工作区仍会如此）。
这意味着命名工作区在更多情况下会“粘附”到其原始输出上，以体现其更永久的特性。
当然，如果用户手动将命名工作区移动到另一台显示器，其原始输出仍会随之更新。

### 布局配置覆写 {#layout-config-overrides}

<sup>Since: next release</sup>

您可以使用 `layout {}` 块为命名工作区自定义布局设置：

```kdl
workspace "aesthetic" {
    // 仅针对此命名工作区的布局配置覆写。
    layout {
        gaps 32

        struts {
            left 64
            right 64
            bottom 64
            top 64
        }

        border {
            on
            width 4
        }

        // ...任何其他设置。
    }
}
```

它接受与[顶级层级 `layout {}` 配置段](./Configuration:-Layout.md)相同的所有选项，除了：

- `empty-workspace-above-first`：这是一个输出级别的设置，在工作区上没有意义。
- `insert-hint`：目前我们始终在输出级别绘制这些提示，因此不能按工作区自定义。

要取消设置某个参数，请将其写为 `false`，例如：

```kdl
layout {
    // 全局启用。
    always-center-single-column
}

workspace "uncentered" {
    layout {
        // 在此工作区上取消设置。
        always-center-single-column false
    }
}
```
