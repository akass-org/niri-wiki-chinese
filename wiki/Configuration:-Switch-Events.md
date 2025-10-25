### 概述

<sup>Since: 0.1.10</sup>

开关事件绑定在配置文件的 `switch-events {}` 部分中声明。

以下是您可以绑定的所有事件一览：

```kdl
switch-events {
    lid-close { spawn "notify-send" "The laptop lid is closed!"; }
    lid-open { spawn "notify-send" "The laptop lid is open!"; }
    tablet-mode-on { spawn "bash" "-c" "gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true"; }
    tablet-mode-off { spawn "bash" "-c" "gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled false"; }
}
```

其语法与按键绑定类似。
目前，仅支持 [`spawn` 动作](./Configuration:-Key-Bindings.md#spawn)。

> [!NOTE]
> 与按键绑定不同，开关事件绑定*始终*会被执行，即使会话被锁定也不例外。

### `lid-close`, `lid-open`

这些事件对应于笔记本电脑盖的关闭和打开。

请注意，niri 已经会根据笔记本电脑盖的状态自动开启或关闭笔记本电脑内置的显示器。

```kdl
switch-events {
    lid-close { spawn "notify-send" "The laptop lid is closed!"; }
    lid-open { spawn "notify-send" "The laptop lid is open!"; }
}
```

### `tablet-mode-on`, `tablet-mode-off`

当可转换形态的笔记本电脑进入或退出平板模式时，会触发这些事件。
在平板模式下，键盘和鼠标通常无法使用，因此您可以使用这些事件来激活屏幕键盘。

```kdl
switch-events {
    tablet-mode-on { spawn "bash" "-c" "gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true"; }
    tablet-mode-off { spawn "bash" "-c" "gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled false"; }
}
```
