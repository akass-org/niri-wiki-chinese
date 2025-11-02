<sup>Since: next release</sup>

您可以在配置的顶部包含其他文件。

```kdl,must-fail
// 一些设置...

include "colors.kdl"

// 更多设置...
```

被包含的文件与主配置文件具有相同的结构。
来自被包含文件的设置将与主配置文件中的设置合并。

被包含的配置文件可以继续包含更多文件。
所有被包含的文件都会被监视其更改，当其中任何一个文件发生变化时，配置将实时重新加载。

包含操作仅在配置的顶部有效：

```kdl,must-fail
// 正确：在顶部包含。
include "something.kdl"

layout {
    // 不允许：在其他部分内部包含。
    include "other.kdl"
}
```

### 位置性

包含操作具有*位置性*。
它们会覆盖在它们*之前*设置的选项。
来自被包含文件的窗口规则将被插入到 `include` 行所在的位置。
例如：

```kdl
// colors.kdl
layout {
    border {
        active-color "green"
    }
}

overview {
    backdrop-color "green"
}
```

```kdl,must-fail
// config.kdl
layout {
    border {
        active-color "red"
    }
}

// 这会将边框颜色和背景颜色覆盖为绿色。
include "colors.kdl"

// 这会再次将全局概览的背景颜色设置为红色。
overview {
    backdrop-color "red"
}
```

最终结果是：

- 边框颜色为绿色（来自 `colors.kdl`），
- 全局概览背景颜色为红色（它是在 `colors.kdl` *之后*设置的）。

另一个例子：

```kdl
// rules.kdl
window-rule {
    match app-id="Alacritty"
    open-maximized false
}
```

```kdl,must-fail
// config.kdl
window-rule {
    open-maximized true
}

// 窗口规则在此位置插入。
include "rules.kdl"

window-rule {
    match app-id="firefox$"
    open-maximized true
}
```

这等效于以下配置文件：

```kdl
window-rule {
    open-maximized true
}

// 从 rules.kdl 包含。
window-rule {
    match app-id="Alacritty"
    open-maximized false
}

window-rule {
    match app-id="firefox$"
    open-maximized true
}
```

### 合并

大多数配置部分在包含之间会进行合并，这意味着您可以只设置少数几个属性，并且只有这些属性会被更改。

```kdl
// colors.kdl
layout {
    // 不影响间隙、边框宽度等。
    // 仅更改所写的颜色。
    focus-ring {
        active-color "blue"
    }

    border {
        active-color "green"
    }
}
```

```kdl,must-fail
// config.kdl
include "colors.kdl"

layout {
    // 不设置边框和聚焦环颜色，
    // 因此使用 colors.kdl 中的颜色。
    gaps 8

    border {
        width 8
    }
}
```

#### 多部分 sections

像 `window-rule`、`output` 或 `workspace` 这样的多部分配置段会按原样插入，不进行合并：

```kdl
// laptop.kdl
output "eDP-1" {
    // ...
}
```

```kdl,must-fail
// config.kdl
output "DP-2" {
    // ...
}

include "laptop.kdl"

// 最终结果：DP-2 和 eDP-1 的设置都存在。
```

#### 按键绑定

`binds` 会覆盖先前定义的冲突按键：

```kdl
// binds.kdl
binds {
    Mod+T { spawn "alacritty"; }
}
```

```kdl,must-fail
// config.kdl
include "binds.kdl"

binds {
    // 覆盖 binds.kdl 中的 Mod+T。
    Mod+T { spawn "foot"; }
}
```

#### 标志

大多数标志可以通过 `false` 来禁用：

```kdl
// csd.kdl

// 写入 "false" 以明确禁用。
prefer-no-csd false
```

```kdl,must-fail
// config.kdl

// 在主配置中启用 prefer-no-csd。
prefer-no-csd

// 包含 csd.kdl 会再次禁用它。
include "csd.kdl"
```

#### 非合并配置段

某些其内容表示组合结构的配置段不会被合并。
例如 `struts`、`preset-column-widths`、`animations` 中的各个子配置段、`input` 中的指针设备配置段。

```kdl
// struts.kdl
layout {
    struts {
        left 64
        right 64
    }
}
```

```kdl,must-fail
// config.kdl
layout {
    struts {
        top 64
        bottom 64
    }
}

include "struts.kdl"

// Struts 不会被合并。
// 最终结果只有左右 struts。
```

### 边框特殊情况

在主配置和包含配置之间存在一个特殊情况的差异。

在被包含的配置中写入 `layout { border {} }` 不会产生任何效果（因为没有属性被更改）。
然而，在主配置中写入相同内容会*启用*边框，即它等效于 `layout { border { on; } }`。

因此，如果您想将布局配置从主配置移动到单独的文件中，请记得在边框部分添加 `on`，例如：

```kdl
// separate.kdl
layout {
    border {
        // 添加此行：
        on

        width 4
        active-color "#ffc87f"
        inactive-color "#505050"
    }
}
```

这种特殊情况的原因是它历史上的工作方式：当初我添加边框时，我们没有任何 `on` 标志，所以我让写入 `border {}` 部分来启用边框，并通过显式的 `off` 来禁用它。
现在更改它不会有太大问题，但是默认配置总是有一个预填充的 `layout { border { off; } }` 部分，并附有注释说明注释掉 `off` 就足以启用边框。
现在许多人很可能在其配置中嵌入了默认配置的这一部分，因此更改其工作方式只会引起很多困惑。
