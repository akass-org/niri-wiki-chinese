本页记录了所有没有单独设页的顶级层级（top-level）配置选项。

以下是所有这些选项的概览：

```kdl
spawn-at-startup "waybar"
spawn-at-startup "alacritty"
spawn-sh-at-startup "qs -c ~/source/qs/MyAwesomeShell"

prefer-no-csd

screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

environment {
    QT_QPA_PLATFORM "wayland"
    DISPLAY null
}

cursor {
    xcursor-theme "breeze_cursors"
    xcursor-size 48

    hide-when-typing
    hide-after-inactive-ms 1000
}

overview {
    zoom 0.5
    backdrop-color "#262626"

    workspace-shadow {
        // off
        softness 40
        spread 10
        offset x=0 y=10
        color "#00000050"
    }
}

xwayland-satellite {
    // off
    path "xwayland-satellite"
}

clipboard {
    disable-primary
}

hotkey-overlay {
    skip-at-startup
    hide-not-bound
}

config-notification {
    disable-failed
}
```

### `spawn-at-startup`

添加类似这样的行，以便在 niri 启动时启动进程。

`spawn-at-startup` 接受程序二进制文件的路径作为第一个参数，后跟程序的参数。

此选项的工作方式与 [`spawn` 键绑定动作](./Configuration:-Key-Bindings.md#spawn)相同，因此请阅读该处以了解其所有细节。

```kdl
spawn-at-startup "waybar"
spawn-at-startup "alacritty"
```

请注意，将 niri 作为 systemd 会话运行时，默认就支持 xdg-desktop-autostart，这可能更方便使用。
得益于此，您在 GNOME 中配置为自启动的应用，在 niri 中也将“正常工作”，无需任何手动的 `spawn-at-startup` 配置。

### `spawn-sh-at-startup`

<sup>Since: 25.08</sup>

添加类似这样的行，以便在 niri 启动时运行 shell 命令。

该参数是一个纯字符串，会原封不动地传递给 `sh`。
因此，您可以如常使用 shell 变量、管道、`~` 展开以及其他所有功能。

请参阅 [`spawn-sh` 按键绑定动作](./Configuration:-Key-Bindings.md#spawn-sh)文档中的详细描述。

```kdl
// 在一个字符串中传递所有参数。
spawn-sh-at-startup "qs -c ~/source/qs/MyAwesomeShell"
```

### `prefer-no-csd`

此标志将使 niri 请求应用程序省略其客户端装饰。

如果应用程序明确请求 CSD，则该请求将被接受。
此外，客户端将被告知它们处于平铺状态，从而移除一些圆角。

设置 `prefer-no-csd` 后，通过 xdg-decoration 协议使用服务器端装饰的应用，将只绘制焦点环和边框，而*不会*有纯色背景。。

> [!NOTE]
> 与大多数其他选项不同，更改 `prefer-no-csd` 不会完全生效于正在运行的应用程序。
> 它会使某些窗口变为矩形，但去不掉标题栏。
> 这主要是因为 niri 为了绕过 [SDL2 中的一个 Bug](https://github.com/libsdl-org/SDL/issues/8173)，该 Bug 会阻止 SDL2 应用程序启动。
>
> 在配置中更改 `prefer-no-csd` 后，请重启应用程序以完全应用更改。

```kdl
prefer-no-csd
```

### `screenshot-path`

设置截图保存的路径。
开头的 `~` 将被展开为用户主目录。

该路径使用 `strftime(3)` 进行格式化，以便为您提供截图的日期和时间。

如果路径的最后一个文件夹不存在，Niri 将会创建它。

```kdl
screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
```

您也可以将此选项设置为 `null` 以禁用将截图保存到磁盘。

```kdl
screenshot-path null
```

### `environment`

覆写由 niri 启动的进程的环境变量。

```kdl
environment {
    // 像这样设置变量：
    // QT_QPA_PLATFORM "wayland"

    // 使用 null 值来移除变量：
    // DISPLAY null
}
```

### `cursor`

通过设置 `XCURSOR_THEME` 和 `XCURSOR_SIZE` 环境变量，来更改光标的主题和大小。

```kdl
cursor {
    xcursor-theme "breeze_cursors"
    xcursor-size 48
}
```

#### `hide-when-typing`

<sup>Since: 0.1.10</sup>

如果设置，则在按下键盘上的键时隐藏光标。

> [!NOTE]
> 此设置可能会干扰在原生 Wayland 模式下运行并使用鼠标视角的 Wine 游戏，例如第一人称游戏。
> 如果当您同时按键和移动鼠标时，角色的视角会向下跳转，请尝试禁用此设置。

```kdl
cursor {
    hide-when-typing
}
```

#### `hide-after-inactive-ms`

<sup>Since: 0.1.10</sup>

如果设置，则自上次光标移动起经过此毫秒数后，光标将自动隐藏。

```kdl
cursor {
    // 在闲置一秒后隐藏光标。
    hide-after-inactive-ms 1000
}
```

### `overview`

<sup>Since: 25.05</sup>

[桌面概览](./Overview.md)中的设置。

#### `zoom`

控制在概览中工作区缩小的程度。
`zoom` 的范围从 0 到 0.75，值越小，所有内容就越小。

```kdl
// 在概览中使工作区比正常小四倍。
overview {
    zoom 0.25
}
```

#### `backdrop-color`

设置概览中工作区背后的背景色。
在切换工作区时，工作区之间也会显示此背景色。

此颜色的 Alpha 通道将会被忽略。

```kdl
// 让背景亮一点。
overview {
    backdrop-color "#777777"
}
```

您也可以在[输出配置](./Configuration:-Outputs.md#backdrop-color)中为每个输出单独设置颜色。

#### `workspace-shadow`

控制在概览中可见的工作区背后的阴影。

此处的配置项照抄了布局部分中常规的 [`shadow` 配置](./Configuration:-Layout.md#shadow)，因此请查看那里的文档说明。

工作区阴影是先按高度为 1080 像素的标准工作区配置的，然后再随工作区一起缩放。
因此这意味着实际使用时，您需要相较于窗口阴影设置更大的扩散、偏移和柔和度。

```kdl
// 在概览中禁用工作区阴影。
overview {
    workspace-shadow {
        off
    }
}
```

### `xwayland-satellite`

<sup>Since: 25.08</sup>

与 [xwayland-satellite](https://github.com/Supreeeme/xwayland-satellite) 集成的设置。

当检测到足够新的 xwayland-satellite 时，niri 会创建 X11 套接字并设置 `DISPLAY`，之后，一旦有 X11 客户端尝试连接，niri 便会自动启动 `xwayland-satellite`。
如果 Xwayland 崩溃，niri 会继续监听 X11 套接字，并在需要时重启 `xwayland-satellite`。
这与其他合成器中内置 Xwayland 的工作方式非常相似。

`off` 禁用集成：niri 不会创建 X11 套接字，也不会设置 `DISPLAY` 环境变量。

`path` 用于设置 `xwayland-satellite` 二进制文件的路径。
默认情况下，该值就是 `xwayland-satellite`，因此会像查找其他非绝对路径的程序名一样来搜索它。

```kdl
// 使用 xwayland-satellite 的自定义构建。
xwayland-satellite {
    path "~/source/rs/xwayland-satellite/target/release/xwayland-satellite"
}
```

### `clipboard`

<sup>Since: 25.02</sup>

剪贴板设置。

设置 `disable-primary` 标志以禁用主剪贴板（中键粘贴）。
切换此标志将仅适用于之后启动的应用程序。

```kdl
clipboard {
    disable-primary
}
```

### `hotkey-overlay`

“重要快捷键”覆盖层的设置。

#### `skip-at-startup`

如果您不想在 niri 启动时看到快捷键帮助，请设置 `skip-at-startup` 标志。

```kdl
hotkey-overlay {
    skip-at-startup
}
```

#### `hide-not-bound`

<sup>Since: 25.08</sup>

默认情况下，niri 仍会显示最重要的动作，即使它们未绑定到任何键，以防混淆。
如果您想隐藏所有未绑定到任何键的动作，请设置 `hide-not-bound` 标志。

```kdl
hotkey-overlay {
    hide-not-bound
}
```

您可以使用 [`hotkey-overlay-title` 属性](./Configuration:-Key-Bindings.md#custom-hotkey-overlay-titles)自定快捷键覆盖层显示的绑定。

### `config-notification`

<sup>Since: 25.08</sup>

配置创建/失败时通知的设置。

设置 `disable-failed` 标志，可以禁用“解析配置文件失败”的通知。
比如，如果您已用自己的方式来处理这类错误。

```kdl
config-notification {
    disable-failed
}
```
