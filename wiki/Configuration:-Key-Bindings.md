### 概述

按键绑定在配置文件的 `binds {}` 配置段中声明。

> [!NOTE]
> 这是少数几个如果省略，*不会*自动填充默认配置的部分之一，因此请确保从默认配置中复制它。

每个绑定都由一个快捷键和一个用花括号括起来的动作组成。
例如：

```kdl
binds {
    Mod+Left { focus-column-left; }
    Super+Alt+L { spawn "swaylock"; }
}
```

快捷键由 `+` 号分隔的修饰键组成和一个末尾的 XKB 按键名称组成。

有效的修饰键有：

- `Ctrl` 或 `Control`；
- `Shift`；
- `Alt`；
- `Super` 或 `Win`；
- `ISO_Level3_Shift` 或 `Mod5` ——在某些布局下这是 AltGr 键；
- `ISO_Level5_Shift`：可以与 xkb lv5 选项（如 `lv5:caps_switch`）一起搭配使用；
- `Mod`。

`Mod` 是一个特殊的修饰键，当 niri 在 TTY 中运行时，它等同于 `Super`；当 niri 作为嵌套的 winit 窗口运行时，它等同于 `Alt`。
这样的话，您就可以在窗口中测试 niri，而不会与宿主机合成器的按键绑定产生太多冲突。
因此，大部分默认快捷键都使用了 `Mod` 修饰键。

<sup>Since: 25.05</sup> 您可以在配置文件的 [`input` 配置段](./Configuration:-Input.md#mod-key-mod-key-nested)中自定义 `Mod` 键。

> [!TIP]
> 要查找特定键的 XKB 名称，您可以使用像 [`wev`](https://git.sr.ht/~sircmpwn/wev) 这类程序。
>
> 在终端中打开它，然后按下您想要检测的键。
> 在终端中，您会看到类似这样的输出：
>
> ```
> [14:     wl_keyboard] key: serial: 757775; time: 44940343; key: 113; state: 1 (pressed)
>                       sym: Left         (65361), utf8: ''
> [14:     wl_keyboard] key: serial: 757776; time: 44940432; key: 113; state: 0 (released)
>                       sym: Left         (65361), utf8: ''
> [14:     wl_keyboard] key: serial: 757777; time: 44940753; key: 114; state: 1 (pressed)
>                       sym: Right        (65363), utf8: ''
> [14:     wl_keyboard] key: serial: 757778; time: 44940846; key: 114; state: 0 (released)
>                       sym: Right        (65363), utf8: ''
> ```
>
> 在这里，请看 `sym: Left` 和 `sym: Right`：这些就是按键名称。
> 在这个例子中，我按下的是左键和右键。
>
> 请注意，绑定 Shift 组合键时，需要根据您的 XKB 布局，明确写出 Shift 以及该键未按下 Shift 时的原始名称。
> 例如，在美式 QWERTY 布局中，<kbd>&lt;</kbd> 位于 <kbd>Shift</kbd> + <kbd>,</kbd> 上，因此要绑定它，您需要写成类似 `Mod+Shift+Comma` 的内容。
>
> 再举一个例子，如果您配置了法语服 [BÉPO](https://en.wikipedia.org/wiki/B%C3%89PO) XKB 布局，您的 <kbd>&lt;</kbd> 位于 <kbd>AltGr</kbd> + <kbd>«</kbd> 上。
> <kbd>AltGr</kbd> 是 `ISO_Level3_Shift`，或等效的 `Mod5`，因此要绑定它，您需要写成类似 `Mod+Mod5+guillemotleft` 的内容。
>
> 在解析拉丁字母键时，niri 会搜索**第一个*配置了该拉丁字母键的 XKB 布局。
> 所以举个例子，如果同时配置了美式 QWERTY 和俄语 (RU) 布局，那么拉丁字母的快捷键将使用美式 QWERTY 布局来解析。

<sup>Since: 0.1.8</sup> 绑定默认会重复（即按住绑定键会使其重复触发）。
您可以使用 `repeat=false` 为特定绑定禁用此功能：

```kdl
binds {
    Mod+T repeat=false { spawn "alacritty"; }
}
```

绑定也可以设置冷却时间，这将限制绑定的触发速率，防止其过快地重复触发。

```kdl
binds {
    Mod+T cooldown-ms=500 { spawn "alacritty"; }
}
```

这主要用于滚动类的绑定。

### 滚动绑定

您可以使用以下语法来绑定鼠标滚轮的滚动事件。
这些绑定的方向会根据 `natural-scroll` 设置而改变。

```kdl
binds {
    Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
    Mod+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }
    Mod+WheelScrollRight                { focus-column-right; }
    Mod+WheelScrollLeft                 { focus-column-left; }
}
```

类似地，您可以绑定触摸板滚动“刻度”。
触摸板的滚动是连续的，因此对于这些绑定，它会根据移动的距离分成离散的间隔。

这些绑定也受触摸板的 `natural-scroll` 影响，因此这些示例绑定是“反向”的，因为 niri 默认为触摸板启用了 `natural-scroll`。

```kdl
binds {
    Mod+TouchpadScrollDown { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02+"; }
    Mod+TouchpadScrollUp   { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02-"; }
}
```

当鼠标滚轮和触摸板滚动绑定的修饰键被按下时，应用程序将无法接收到任何滚动事件。
例如，假设您有一个 `Mod+WheelScrollDown` 绑定，那么在按住 `Mod` 时，所有鼠标滚轮滚动都将被 niri 捕获。

### 鼠标点击绑定

<sup>Since: 25.01</sup>

您可以使用以下语法来绑定鼠标点击。

```kdl
binds {
    Mod+MouseLeft    { close-window; }
    Mod+MouseRight   { close-window; }
    Mod+MouseMiddle  { close-window; }
    Mod+MouseForward { close-window; }
    Mod+MouseBack    { close-window; }
}
```

鼠标点击操作的是点击的那一刻已获得焦点的窗口，而不是您正在点击的窗口。

请注意，绑定 `Mod+MouseLeft` 或 `Mod+MouseRight` 将覆盖相应的手势操作（移动或调整窗口大小）。

### 自定义快捷键悬浮窗标题 {#custom-hotkey-overlay-titles}

<sup>Since: 25.02</sup>

快捷键悬浮窗（即重要快捷键对话框）会显示一个硬编码的绑定列表。
您可以使用 `hotkey-overlay-title` 属性来自定义此列表。

要将一个绑定添加到悬浮窗里，请将该属性设置为您想要显示的标题：
```kdl
binds {
    Mod+Shift+S hotkey-overlay-title="切换深色/浅色样式" { spawn "some-script.sh"; }
}
```

带有自定义标题的快捷键会列在硬编码快捷键之后，以及未自定义的 Spawn 快捷键之前。

要从快捷键悬浮窗中移除硬编码的绑定，请将该属性设置为 null：
```kdl
binds {
    Mod+Q hotkey-overlay-title=null { close-window; }
}
```

> [!TIP]
> 当多个按键组合绑定到同一操作时：
> - 如果其中任何一个绑定具有自定义的悬浮窗标题，niri 将显示该绑定。
> - 否则，如果其中任何一个绑定标题为 null，则 niri 将隐藏该绑定。
> - 否则，niri 将显示第一个按键组合。

自定义标题支持 [Pango 标记语言](https://docs.gtk.org/Pango/pango_markup.html)：

```kdl
binds {
    Mod+Shift+S hotkey-overlay-title="<b>切换</b> <span foreground='red'>深色</span>/浅色样式" { spawn "some-script.sh"; }
}
```

![自定义标记示例。](https://github.com/user-attachments/assets/2a2ba914-bfa7-4dfa-bb5e-49839034765d)

### 动作

您可以绑定的每个动作，也都可通过 `niri msg action` 命令以编程方式化调用。
运行 `niri msg action` 可获取一份包含所有动作及其简短描述的完整列表。

以下是一些需要更多解释的动作。

#### `spawn`

启动一个程序。

`spawn` 接受程序二进制文件的路径作为第一个参数，随后是程序的参数。
例如：

```kdl
binds {
    // 启动 alacritty。
    Mod+T { spawn "alacritty"; }

    // 启动 `wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+`。
    XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
}
```

> [!TIP]
>
> <sup>Since: 0.1.5</sup>
>
> Spawn 绑定有一个特殊的 `allow-when-locked=true` 属性，使其即使在会话锁定时也能工作：
>
> ```kdl
> binds {
>     // 即使在会话锁定时，此静音绑定也能工作。
>     XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
> }
> ```

对于 `spawn`，niri *不会* 通过 Shell 来运行命令，这意味着您需要手动分隔参数。
有关使用 Shell 的动作，请参阅下面的 [`spawn-sh`](#spawn-sh)。

```kdl
binds {
    // 正确：每个参数都用独立的引号括起来。
    Mod+T { spawn "alacritty" "-e" "/usr/bin/fish"; }

    // 错误：这会将整个 `alacritty -e /usr/bin/fish` 字符串解释为二进制文件路径。
    Mod+D { spawn "alacritty -e /usr/bin/fish"; }

    // 错误：这会将 `-e /usr/bin/fish` 作为单个参数传递，alacritty 将无法理解。
    Mod+Q { spawn "alacritty" "-e /usr/bin/fish"; }
}
```

这也意味着您无法展开环境变量或 `~`。
如果需要这类功能，您可以手动通过运行 Shell 来执行命令。

```kdl
binds {
    // 错误：此处没有 shell 展开。这些字符串将按原样传递给程序。
    Mod+T { spawn "grim" "-o" "$MAIN_OUTPUT" "~/screenshot.png"; }

    // 正确：手动通过 shell 运行此命令，以便它可以展开参数。
    // 请注意，整个命令是作为 单个 参数传递的，
    // 因为 shell 将根据自己的规则按空格分隔参数。
    Mod+D { spawn "sh" "-c" "grim -o $MAIN_OUTPUT ~/screenshot.png"; }

    // 您还可以使用 shell 运行多个命令，
    // 使用管道、进程替换等。
    Mod+Q { spawn "sh" "-c" "notify-send clipboard \"$(wl-paste)\""; }
}
```

作为一种特殊情况，niri 只会在程序名称的开头将 `~` 扩展到主目录。

```kdl
binds {
    // 这将工作：一个 ~ 在最开头。
    Mod+T { spawn "~/scripts/do-something.sh"; }
}
```

#### `spawn-sh`

<sup>Since: 25.08</sup>

通过 shell 运行命令。

其参数是一个直接传递给 `sh` 的字符串。
您可以使用 shell 变量、管道、`~` 展开以及所有其他期望的所有功能。

```kdl
binds {
    // 适用于 spawn-sh：所有参数在同一字符串中。
    Mod+D { spawn-sh "alacritty -e /usr/bin/fish"; }

    // 适用于 spawn-sh：shell 变量（$MAIN_OUTPUT）、~ 展开。
    Mod+T { spawn-sh "grim -o $MAIN_OUTPUT ~/screenshot.png"; }

    // 适用于 spawn-sh：进程替换。
    Mod+Q { spawn-sh "notify-send clipboard \"$(wl-paste)\""; }

    // 适用于 spawn-sh：多个命令。
    Super+Alt+S { spawn-sh "pkill orca || exec orca"; }
}
```

`spawn-sh "some command"` 等同于 `spawn "sh" "-c" "some command"` ——这只是一个更不易令人混淆的简写。
请注意，与直接 `spawn` 某个二进制文件相比，通过 shell 启动则会产生微小的性能开销。

使用 `sh` 是硬编码的，这与其他合成器一致。
如果您想要不同的 shell，请使用 `spawn` 写出来，例如 `spawn "fish" "-c" "某个 fish 命令"`。

#### `quit`

退出 niri，但会先显示确认对话框以避免意外触发。

```kdl
binds {
    Mod+Shift+E { quit; }
}
```

如果您想跳过确认对话框，请按如下方式设置参数：

```kdl
binds {
    Mod+Shift+E { quit skip-confirmation=true; }
}
```

#### `do-screen-transition`

<sup>Since: 0.1.6</sup>

短暂冻结屏幕，然后淡入到新内容。

```kdl
binds {
    Mod+Return { do-screen-transition; }
}
```

此动作主要用于从更改系统主题或样式（例如在深色和浅色之间切换）的脚本中触发。
它使诸如窗口逐个更改样式之类的过渡看起来平滑且同步。

例如，使用 GNOME 颜色方案设置：

```shell
niri msg action do-screen-transition
dconf write /org/gnome/desktop/interface/color-scheme "\"prefer-dark\""
```

默认情况下，屏幕会冻结 250 毫秒以给窗口时间重绘，然后进行淡入淡出。
您可以像这样设置此延迟：

```kdl
binds {
    Mod+Return { do-screen-transition delay-ms=100; }
}
```

或者，在脚本中：

```shell
niri msg action do-screen-transition --delay-ms 100
```

#### `toggle-window-rule-opacity`

<sup>Since: 25.02</sup>

切换聚焦窗口的不透明度窗口规则。
只有当窗口的不透明度规则已设置为半透明时，此操作才有效。

```kdl
binds {
    Mod+O { toggle-window-rule-opacity; }
}
```

#### `screenshot`, `screenshot-screen`, `screenshot-window`

用于截取屏幕截图的动作。

- `screenshot`：打开内置的交互式截图界面。
- `screenshot-screen`, `screenshow-window`：分别对聚焦的屏幕或窗口进行截图。

截图会根据 [`screenshot-path` 选项](./Configuration:-Miscellaneous.md#screenshot-path)同时存储到剪贴板和保存到磁盘。

<sup>Since: 25.02</sup> 您可以使用 `write-to-disk=false` 属性为特定绑定禁用保存到磁盘：

```kdl
binds {
    Ctrl+Print { screenshot-screen write-to-disk=false; }
    Alt+Print { screenshot-window write-to-disk=false; }
}
```

在交互式截图界面中，按下 <kbd>Ctrl</kbd><kbd>C</kbd> 可以将截图复制到剪贴板，而不写入磁盘。

<sup>Since: 25.05</sup> 您可以使用 `show-pointer=false` 属性在截图中隐藏鼠标指针：

```kdl
binds {
    // 指针将默认隐藏
    //（您仍然可以按 P 显示它）。
    Print { screenshot show-pointer=false; }

    // 指针将在截图中隐藏。
    Ctrl+Print { screenshot-screen show-pointer=false; }
}
```

#### `toggle-keyboard-shortcuts-inhibit`

<sup>Since: 25.02</sup>

一些应用程序，如远程桌面客户端和软件 KVM 切换器，可能会请求 niri 停止处理自身的键盘快捷键，以便它们能够（比如说）将按键按原样转发到远程机器。
`toggle-keyboard-shortcuts-inhibit` 是一个切换抑制器的逃生舱口。
最好为其绑定一个快捷键，这样有问题的应用程序就无法劫持您的会话。

```kdl
binds {
    Mod+Escape { toggle-keyboard-shortcuts-inhibit; }
}
```

您还可以使用 `allow-inhibiting=false` 属性使某些绑定忽略抑制。
它们将始终由 niri 处理，永远不会传递给窗口。

```kdl
binds {
    // 此绑定将始终有效，即使在使用虚拟机时也是如此。
    Super+Alt+L allow-inhibiting=false { spawn "swaylock"; }
}
```
