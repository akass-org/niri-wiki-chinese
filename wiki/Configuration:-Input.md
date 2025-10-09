### 概述

在本节中，您可以配置键盘和鼠标等输入设备，以及一些与输入相关的选项。

每种设备类型都有对应的配置段：`keyboard`（键盘）、`touchpad`（触摸板）、`mouse`（鼠标）、`trackpoint`（指点杆）、`tablet`（数位板）、`touch`（触摸屏）。
这些配置段中的设置将应用于该类型的所有设备。
目前，尚无法为特定设备单独进行配置（但此功能已在计划中）。

所有设置一览：

```kdl
input {
    keyboard {
        xkb {
            // layout "us"
            // variant "colemak_dh_ortho"
            // options "compose:ralt,ctrl:nocaps"
            // model ""
            // rules ""
            // file "~/.config/keymap.xkb"
        }

        // repeat-delay 600
        // repeat-rate 25
        // track-layout "global"
        numlock
    }

    touchpad {
        // off
        tap
        // dwt
        // dwtp
        // drag false
        // drag-lock
        natural-scroll
        // accel-speed 0.2
        // accel-profile "flat"
        // scroll-factor 1.0
        // scroll-factor vertical=1.0 horizontal=-2.0
        // scroll-method "two-finger"
        // scroll-button 273
        // scroll-button-lock
        // tap-button-map "left-middle-right"
        // click-method "clickfinger"
        // left-handed
        // disabled-on-external-mouse
        // middle-emulation
    }

    mouse {
        // off
        // natural-scroll
        // accel-speed 0.2
        // accel-profile "flat"
        // scroll-factor 1.0
        // scroll-factor vertical=1.0 horizontal=-2.0
        // scroll-method "no-scroll"
        // scroll-button 273
        // scroll-button-lock
        // left-handed
        // middle-emulation
    }

    trackpoint {
        // off
        // natural-scroll
        // accel-speed 0.2
        // accel-profile "flat"
        // scroll-method "on-button-down"
        // scroll-button 273
        // scroll-button-lock
        // left-handed
        // middle-emulation
    }

    trackball {
        // off
        // natural-scroll
        // accel-speed 0.2
        // accel-profile "flat"
        // scroll-method "on-button-down"
        // scroll-button 273
        // scroll-button-lock
        // left-handed
        // middle-emulation
    }

    tablet {
        // off
        map-to-output "eDP-1"
        // left-handed
        // calibration-matrix 1.0 0.0 0.0 0.0 1.0 0.0
    }

    touch {
        // off
        map-to-output "eDP-1"
        // calibration-matrix 1.0 0.0 0.0 0.0 1.0 0.0
    }

    // disable-power-key-handling
    // warp-mouse-to-focus
    // focus-follows-mouse max-scroll-amount="0%"
    // workspace-auto-back-and-forth

    // mod-key "Super"
    // mod-key-nested "Alt"
}
```

### 键盘

#### 布局

在 `xkb` 配置段中，您可以设置布局（layout）、变体（variant）、选项（options）、型号（model）和规则（rules）。
这些设置将会直接传递给 libxkbcommon，大多数其他 Wayland 合成器也使用改库。
有关更多信息，请参阅 `xkeyboard-config(7)` 手册。

```kdl
input {
    keyboard {
        xkb {
            layout "us"
            variant "colemak_dh_ortho"
            options "compose:ralt,ctrl:nocaps"
        }
    }
}
```

> [!TIP]
>
> <sup>Since: 25.02</sup>
>
> 或者，您可以直接设置包含 xkb 键盘映射的 .xkb 文件的路径。
> 这将覆盖所有其他 xkb 设置。
>
> ```kdl
> input {
>     keyboard {
>         xkb {
>             file "~/.config/keymap.xkb"
>         }
>     }
> }
> ```

> [!NOTE]
>
> <sup>Since: 25.08</sup>
>
> 如果 `xkb` 配置段为空（默认情况下就是空的），niri 将通过 D-Bus 从 systemd-localed 的 `org.freedesktop.locale1` 服务获取 xkb 设置。
> 通过这种方式，例如系统安装程序，就可以动态设置 niri 的键盘布局。
> 您可以在 `localectl` 中查看此布局，并使用 `localectl set-x11-keymap` 进行更改，例如：
>
> ```sh
> $ localectl set-x11-keymap "us" "" "colemak_dh_ortho" "compose:ralt,ctrl:nocaps"
> $ localectl
> System Locale: LANG=en_US.UTF-8
>                LC_NUMERIC=ru_RU.UTF-8
>                LC_TIME=ru_RU.UTF-8
>                LC_MONETARY=ru_RU.UTF-8
>                LC_PAPER=ru_RU.UTF-8
>                LC_MEASUREMENT=ru_RU.UTF-8
>     VC Keymap: us-colemak_dh_ortho
>    X11 Layout: us
>   X11 Variant: colemak_dh_ortho
>   X11 Options: compose:ralt,ctrl:nocaps
> ```
>
> 默认情况下，`localectl` 会将 TTY 键盘映射设置为最接近 XKB 键盘映射的匹配项。
> 您可以使用 `--no-convert` 参数来阻止这种行为，例如：`localectl set-x11-keymap --no-convert "us,ru"`。
>
> 其他一些程序（如 GDM）也会采用这些设置。

当使用多个布局时，niri 可以全局记住当前布局（默认），也可以为每个窗口单独记忆。
您可以使用 `track-layout` 选项来控制这一行为。

- `global`：布局更改对所有窗口全局生效。
- `window`：为每个窗口单独跟踪布局。

```kdl
input {
    keyboard {
        track-layout "global"
    }
}
```

#### 重复

延迟（repeat-delay）是指键盘开始重复按键前的等待时间，单位为毫秒。
速率（repeat-rate）是指每秒重复的字符数。

```kdl
input {
    keyboard {
        repeat-delay 600
        repeat-rate 25
    }
}
```

#### 数字锁定（Num Lock）

<sup>Since: 25.05</sup>

设置 `numlock` 标志可在启动时自动开启数字锁定。

如果您使用的笔记本电脑键盘将数字锁定键叠加在常规键位上，您可能需要禁用（注释掉）`numlock`。

```kdl
input {
    keyboard {
        numlock
    }
}
```

### 指针设备

指针设备的大多数设置都将直接传递给 libinput。
其他 Wayland 合成器也使用 libinput，因此您很可能在那里找到相同的设置。
对于 `tap` 这样的参数，省略它们或将其注释掉即可禁用该设置。

一些设置在输入设备之间是通用的：

- `off`：如果设置，将不会从此设备发送任何事件。

一些设置在 `touchpad`（触摸板）、`mouse`（鼠标）、`trackpoint`（指点杆）和 `trackball`（轨迹球）之间是通用的：

- `natural-scroll`：如果设置，则反转滚动方向。
- `accel-speed`：指针加速速度，有效值范围为 `-1.0` 到 `1.0`，默认为 `0.0`。
- `accel-profile`：可以是 `adaptive`（自适应，默认值）或 `flat`（禁用指针加速）。
- `scroll-method`：何时生成滚动事件而不是指针移动事件，可以是 `no-scroll`（无滚动）、`two-finger`（双指）、`edge`（边缘）或 `on-button-down`（按下按钮时）。
  默认值和支持的方法因设备类型而异。
- `scroll-button`：<sup>Since: 0.1.10</sup> 用于 `on-button-down` 滚动方法的按钮代码。您可以在 `libinput debug-events` 中找到它。
- `scroll-button-lock`：<sup>Since: 25.08</sup> 启用后，无需持续按住按钮。按一次即可开始滚动，再按一次停止，双击则相当于单击底层按钮。
- `left-handed`：如果设置，则将设备切换到左手模式。
- `middle-emulation`：通过同时按下鼠标左键和右键来模拟中键点击。

`touchpad`（触摸板）独有的设置：

- `tap`：轻触点击。
- `dwt`：打字时禁用。
- `dwtp`：使用指点杆时禁用。
- `drag`：<sup>Since: 25.05</sup> 可以是 `true` 或 `false`，控制是否启用轻触拖拽。
- `drag-lock`：<sup>Since: 25.02</sup> 如果设置，在拖拽过程中短暂抬起手指不会放下被拖拽的项目。请参阅 [libinput 文档](https://wayland.freedesktop.org/libinput/doc/latest/tapping.html#tap-and-drag)。
- `tap-button-map`：可以是 `left-right-middle` 或 `left-middle-right`，控制哪个按钮对应双指轻触和三指轻触。
- `click-method`：可以是 `button-areas` 或 `clickfinger`，更改[点击方法](https://wayland.freedesktop.org/libinput/doc/latest/clickpad-softbuttons.html)。
- `disabled-on-external-mouse`：当插入外部指针设备时，不发送触控板事件。

`touchpad`（触摸板）和 `mouse`（鼠标）独有的设置：

- `scroll-factor`：<sup>Since: 0.1.10</sup> 按此值缩放滚动速度。

    <sup>Since: 25.08</sup> 您还可以像这样分别覆盖水平和垂直滚动因子：`scroll-factor horizontal=2.0 vertical=-1.0`

`tablet`（数位板）和 `touch`（触摸屏）独有的设置：

- `calibration-matrix`：设置为六个浮点数以更改校准矩阵。示例请参阅 [`LIBINPUT_CALIBRATION_MATRIX` 文档](https://wayland.freedesktop.org/libinput/doc/latest/device-configuration-via-udev.html)。
    - <sup>Since: 25.02</sup> 适用于 `tablet`
    - <sup>Since: next release</sup> 适用于 `touch`

数位板和触摸屏是绝对定位设备，可以映射到特定的输出，如下所示：

```kdl
input {
    tablet {
        map-to-output "eDP-1"
    }

    touch {
        map-to-output "eDP-1"
    }
}
```

有效的输出名称与输出配置中使用的名称相同。

<sup>Since: 0.1.7</sup> 当数位板未映射到任何输出时，它将映射到所有已连接输出的并集区域，不进行宽高比校正。

### 通用设置

这些设置不针对于特定的输入设备。

#### `disable-power-key-handling`

默认情况下，niri 会接管电源按钮，使其进入睡眠状态而不是关机。
如果您想在其他地方（如 `logind.conf`）配置电源按钮，请设置此项。

```kdl
input {
    disable-power-key-handling
}
```

#### `warp-mouse-to-focus`

使鼠标自动跳转到新获得焦点的窗口。

如果光标原本是隐藏的，此设置也不会使其可见。

```kdl
input {
    warp-mouse-to-focus
}
```

默认情况下，光标会*分别*在水平和垂直方向上进行跳转。
也就是说，如果仅水平移动鼠标就足以使光标进入新获得焦点的窗口内，那么光标只会水平移动，而不进行垂直移动。

<sup>Since: 25.05</sup> 您可以使用 `mode` 属性自定义此行为。

- `mode="center-xy"`：同时在水平和垂直方向上进行跳转。
因此，只要鼠标位于新获得焦点的窗口之外，它就会跳转到该窗口的中心。
- `mode="center-xy-always"`：同时在水平和垂直方向上进行跳转，即使鼠标已经在新聚焦窗口内的某个位置。

```kdl
input {
    warp-mouse-to-focus mode="center-xy"
}
```

#### `focus-follows-mouse`

当鼠标移过窗口和输出时，自动使其获得焦点。

```kdl
input {
    focus-follows-mouse
}
```

<sup>Since: 0.1.8</sup> 您可以选择设置 `max-scroll-amount`。
这样，如果 focus-follows-mouse 会导致视图滚动超过设定的量，则不会聚焦改窗口。
该值是工作区宽度的百分比。

```kdl
input {
    // 当 focus-follows-mouse 导致滚动最多为屏幕的 10% 时允许。
    focus-follows-mouse max-scroll-amount="10%"
}
```

```kdl
input {
    // 仅当 focus-follows-mouse 不会滚动视图时才允许。
    focus-follows-mouse max-scroll-amount="0%"
}
```

#### `workspace-auto-back-and-forth`

通常，按索引两次切换到同一工作区不会执行任何操作（因为您已经在该工作区上）。
如果启用此标志，通过索引第二次切换到同一个工作区时，将会切换回之前的工作区。

即使工作空间在此期间被重新排序，Niri 也能正确地切换回您之前所在的工作区。

```kdl
input {
    workspace-auto-back-and-forth
}
```

#### `mod-key`、`mod-key-nested`

<sup>Since: 25.05</sup>

自定义[按键绑定](./Configuration:-Key-Bindings.md)中的 `Mod` 键。
只允许有效的修饰符，例如 `Super`、`Alt`、`Mod3`、`Mod5`、`Ctrl`、`Shift`。

默认情况下，在 TTY 上运行 niri 时，`Mod` 等同于 `Super`；在作为嵌套的 winit 窗口中运行 niri 时，`Mod` 等同于 `Alt`。

> [!NOTE]
> 有很多使用 Mod 的默认绑定，它们都不会“穿透”到底层窗口。
> 您可能不希望将 `mod-key` 设置为 Ctrl 或 Shift，因为 Ctrl 通常用于应用程序快捷键，而 Shift 用于常规输入。

```kdl
// 切换 mod 键：正常情况下使用 Alt，在嵌套窗口内使用 Super。
input {
    mod-key "Alt"
    mod-key-nested "Super"
}
```
