### 分段配置文档

您可以在这些 wiki 页面中找到配置文件各个部分的详细文档：

* [输入 `input {}`](./Configuration:-Input.md)
* [输出 `output "eDP-1" {}`](./Configuration:-Outputs.md)
* [绑定 `binds {}`](./Configuration:-Key-Bindings.md)
* [切换事件 `switch-events {}`](./Configuration:-Switch-Events.md)
* [布局 `layout {}`](./Configuration:-Layout.md)
* [顶部层级选项](./Configuration:-Miscellaneous.md)
* [窗口规则 `window-rule {}`](./Configuration:-Window-Rules.md)
* [层级规则 `layer-rule {}`](./Configuration:-Layer-Rules.md)
* [动画 `animations {}`](./Configuration:-Animations.md)
* [手势 `gestures {}`](./Configuration:-Gestures.md)
* [`recent-windows {}`](./Configuration:-Recent-Windows.md)
* [`debug {}`](./Configuration:-Debug-Options.md)
* [包含其他配置 `include "other.kdl"`](./Configuration:-Include.md)

### 加载

Niri 将从 `$XDG_CONFIG_HOME/niri/config.kdl` 或 `~/.config/niri/config.kdl` 加载配置，如果这两个文件都不存在，则会回退到 `/etc/niri/config.kdl`。
如果这两个文件都缺失，niri 将使用在构建时已嵌入到 niri 二进制文件中的 [默认配置文件](https://github.com/YaLTeR/niri/blob/main/resources/default-config.kdl) 的内容创建 `$XDG_CONFIG_HOME/niri/config.kdl`容。
请使用默认配置文件作为自定义配置的起点。

配置支持实时重载。
只需编辑并保存配置文件，您的更改就会立即生效。
这包括按键绑定、输出设置（如模式）、窗口规则以及所有其他配置。

您可以运行 `niri validate` 来解析配置并查看任何错误。

要使用不同的配置文件路径，请通过 `--config` 或 `-c` 参数将其传递给 `niri`。

您也可以设置 `$NIRI_CONFIG` 环境变量指向配置文件路径。
`--config` 参数的优先级始终最高。
如果 `--config` 或 `$NIRI_CONFIG` 指向的不是一个实际存在的文件，则配置将不会被加载。
如果 `$NIRI_CONFIG` 被设置为空字符串，它将被忽略，转而使用默认的配置位置。

### 语法

配置文件使用 [KDL] 编写。

#### 注释

以 `//` 开头的行是注释；它们会被忽略。

此外，您可以在一个代码块前加上 `/-` 来注释掉整个代码块：

```kdl
/-output "eDP-1" {
    // 这里面的所有内容都会被忽略。
    // 显示器不会被关闭，
    // 因为整个代码块都被注释掉了。
    off
}
```

#### 标志

niri 中的切换选项通常表示为标志。
写入该标志则启用它，省略或注释掉它则禁用它。
例如：

```kdl
// “焦点跟随鼠标”已启用。
input {
    focus-follows-mouse

    // 其他设置...
}
```

```kdl
// “焦点跟随鼠标”已禁用。
input {
    // focus-follows-mouse

    // 其他设置...
}
```

#### 配置段

大多数配置段不能重复出现。例如：

```kdl
// 这是有效的：每个配置段只出现一次。
input {
    keyboard {
        // ...
    }

    touchpad {
        // ...
    }
}
```

```kdl,must-fail
// 这是无效的：input 配置段出现了两次。
input {
    keyboard {
        // ...
    }
}

input {
    touchpad {
        // ...
    }
}
```

例外情况也有，是那些通过名称来配置不同设备的配置段，例如：

<!-- NOTE: this may break in the future -->
```kdl
output "eDP-1" {
    // ...
}

// 这是有效的：此配置段配置的是另一个输出。
output "HDMI-A-1" {
    // ...
}

// 这是无效的：“eDP-1” 已经在上面出现过了。
// 这会导致配置解析错误，或者无法正常工作。
output "eDP-1" {
    // ...
}
```

### 默认值

省略配置文件中的大部分配置段将使用该配置段的默认值。
一个显著的例外是 [`binds {}`](./Configuration:-Key-Bindings.md)：它们不会填充默认的按键绑定，因此请确保不要删除这个配置段。

### 破坏性变更策略 {#breaking-change-policy}

通常情况下，niri 的更新不应破坏现有的配置文件。
（举个栗子，在我撰写本文时，niri v0.1.0 的默认配置文件在 v25.02 上仍然可以正常解析。）

对于解析错误（bug），可能会作为例外处理。
例如，niri 曾经允许对同一个按键设置多个绑定，但这并非设计本意，也没有任何作用（总是使用第一个绑定）。
某个补丁版本改变了 niri 的行为，从静默接受此错误变更为抛出解析失败。
这并不是一条硬性规定，在决定进行此类破坏性变更之前，我会仔细评估其潜在影响。

请注意，破坏性变更策略仅适用于 niri 的正式发布版本。
在版本之间的提交中，随着新功能的完善和调整，偶尔可能会破坏配置文件的兼容性。
然而，我会尽量限制这种情况，因为有不少人正在使用 git 构建版本。

[KDL]: https://kdl.dev/
