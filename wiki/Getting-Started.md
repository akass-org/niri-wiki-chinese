获取 niri 最简单的方法是使用包管理器安装。
以下是一些选项：[Fedora COPR](https://copr.fedorainfracloud.org/coprs/yalter/niri/) 和 [nightly COPR](https://copr.fedorainfracloud.org/coprs/yalter/niri-git/)（由我个人维护），[NixOS Flake](https://github.com/sodiboo/niri-flake)，以及下面 repology 中提供的一些更多选项。
如果您想自己编译 niri，请参阅 [构建](#build) 部分；如果您想打包 niri，请参阅 [打包 niri](./Packaging-niri.md) 页面。

[![打包状态](https://repology.org/badge/vertical-allrepos/niri.svg)](https://repology.org/project/niri/versions)

安装后，从您的显示管理器（如 GDM）启动 niri。
按 <kbd>Super</kbd><kbd>T</kbd> 运行终端 ([Alacritty])，按 <kbd>Super</kbd><kbd>D</kbd> 运行应用程序启动器 ([fuzzel])。
要退出 niri，请按 <kbd>Super</kbd><kbd>Shift</kbd><kbd>E</kbd>。

如果您不使用显示管理器，应该在 TTY 运行 `niri-session`（systemd/dinit）或 `niri --session`（其他）。
`--session` 标志会让 niri 将其环境变量全局导入到系统管理器和 D-Bus，并启动其 D-Bus 服务。
`niri-session` 脚本将额外将 niri 作为 systemd/dinit 服务启动，该服务会启动某些服务（如门户）所需的图形会话目标。

您也可以在现有的桌面会话中运行 `niri`。
然后它将作为一个窗口打开，您可以在其中试用它。
请注意，此窗口模式主要用于开发，因此存在一些错误（特别是快捷键方面的问题）。

接下来，请参阅 [重要软件列表](./Important-Software.md)，了解正常桌面使用所需的软件，如通知守护进程和门户。
同时，查看 [配置介绍](./Configuration:-Introduction.md) 页面开始配置 niri。
在那里您可以找到包含所有选项的详细文档和示例的其他页面的链接。
最后，[Xwayland](./Xwayland.md) 页面解释了如何在 niri 上运行 X11 应用程序。

### 桌面环境

一些桌面环境和 shell 可以与 niri 协同工作，并提供更开箱即用的体验：

- [LXQt](https://lxqt-project.org/) 官方支持 niri，有关设置详情，请参阅 [他们的 wiki](https://github.com/lxqt/lxqt/wiki/ConfigWaylandSettings#general)。
- 许多 [XFCE](https://www.xfce.org/) 组件可以在 Wayland 上运行，包括 niri。有关详情，请参阅 [他们的 wiki](https://wiki.xfce.org/releng/wayland_roadmap#component_specific_status)。
- 有一些基于 Quickshell 的完整桌面 shell 支持 niri，例如 [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) 和 [Noctalia](https://github.com/noctalia-dev/noctalia-shell)。
- 您可以使用 [cosmic-ext-extra-sessions](https://github.com/Drakulix/cosmic-ext-extra-sessions) 在 niri 上运行 [COSMIC](https://system76.com/cosmic/) 会话。

### NVIDIA

NVIDIA 驱动程序目前由于堆重用特性存在高显存占用问题。
如果您在 NVIDIA GPU 上运行 niri，建议应用 [此处](./Nvidia.md) 记录的手动修复。

NVIDIA GPU 在运行 niri 时可能会出现问题（例如，从 TTY 启动时屏幕保持黑屏）。
有时，这些问题可以修复。
您可以尝试以下方法：

1. 更新 NVIDIA 驱动程序。您需要足够新的 GPU 和驱动程序以支持 GBM。
2. 确保内核模式设置已启用。这通常涉及将 `nvidia-drm.modeset=1` 添加到内核命令行中。查找并遵循您的发行版的指南。来自其他 Wayland 合成器的指南可能会有所帮助。

### Asahi、ARM 和其他 kmsro 设备

在部分此类系统上，niri 无法正确检测主渲染设备。
如果您在 TTY 上启动 niri 时遇到黑屏，可以尝试手动指定设备。

首先，找出您拥有的设备：

```
$ ls -l /dev/dri/
drwxr-xr-x@       - root 14 мая 07:07 by-path
crw-rw----@   226,0 root 14 мая 07:07 card0
crw-rw----@   226,1 root 14 мая 07:07 card1
crw-rw-rw-@ 226,128 root 14 мая 07:07 renderD128
crw-rw-rw-@ 226,129 root 14 мая 07:07 renderD129
```

您可能有一个 `render` 设备和两个 `card` 设备。

打开位于 `~/.config/niri/config.kdl` 的 niri 配置文件，并像这样将您的 `render` 设备路径填入：

```kdl
debug {
    render-drm-device "/dev/dri/renderD128"
}
```

保存，然后尝试再次启动 niri。
如果仍然出现黑屏，请尝试使用每个 `card` 设备。

### Nix/NixOS

Mesa 驱动与 niri 版本不同步是一个常见问题，因此请确保您的系统 mesa 版本与 niri 的 mesa 版本匹配。
一旦遇到这种情况，您大概率会在从 TTY 尝试启动 niri 时遇到黑屏。

此外，在 Intel 显卡上，您可能需要 [此处](https://wiki.nixos.org/wiki/Intel_Graphics) 描述的变通方法。

### 虚拟机

要在虚拟机中运行 niri，请确保启用了 3D 加速。

## 主要默认快捷键

在 TTY 上运行时，Mod 键是 <kbd>Super</kbd>。
在窗口中运行时，Mod 键是 <kbd>Alt</kbd>。

整体规则如下：如果某个快捷键用于切换目标，那么再添加 <kbd>Ctrl</kbd> 即可将焦点窗口或整列移动到那里。

| 快捷键 | 描述 |
| ------ | ----------- |
| <kbd>Mod</kbd><kbd>Shift</kbd><kbd>/</kbd> | 显示重要的 niri 快捷键列表 |
| <kbd>Mod</kbd><kbd>T</kbd> | 启动 `alacritty`（终端） |
| <kbd>Mod</kbd><kbd>D</kbd> | 启动 `fuzzel`（应用程序启动器） |
| <kbd>Super</kbd><kbd>Alt</kbd><kbd>L</kbd> | 启动 `swaylock`（锁定屏幕） |
| <kbd>Mod</kbd><kbd>Q</kbd> | 关闭焦点窗口 |
| <kbd>Mod</kbd><kbd>H</kbd> 或 <kbd>Mod</kbd><kbd>←</kbd> | 聚焦左侧的一列 |
| <kbd>Mod</kbd><kbd>L</kbd> 或 <kbd>Mod</kbd><kbd>→</kbd> | 聚焦右侧的一列 |
| <kbd>Mod</kbd><kbd>J</kbd> 或 <kbd>Mod</kbd><kbd>↓</kbd> | 聚焦列下方的窗口 |
| <kbd>Mod</kbd><kbd>K</kbd> 或 <kbd>Mod</kbd><kbd>↑</kbd> | 聚焦列上方的窗口 |
| <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>H</kbd> 或 <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>←</kbd> | 将焦点列向左移动 |
| <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>L</kbd> 或 <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>→</kbd> | 将焦点列向右移动 |
| <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>J</kbd> 或 <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>↓</kbd> | 将焦点窗口在列中向下移动 |
| <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>K</kbd> 或 <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>↑</kbd> | 将焦点窗口在列中向上移动 |
| <kbd>Mod</kbd><kbd>Shift</kbd><kbd>H</kbd><kbd>J</kbd><kbd>K</kbd><kbd>L</kbd> 或 <kbd>Mod</kbd><kbd>Shift</kbd><kbd>←</kbd><kbd>↓</kbd><kbd>↑</kbd><kbd>→</kbd> | 聚焦侧面的显示器 |
| <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>Shift</kbd><kbd>H</kbd><kbd>J</kbd><kbd>K</kbd><kbd>L</kbd> 或 <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>Shift</kbd><kbd>←</kbd><kbd>↓</kbd><kbd>↑</kbd><kbd>→</kbd> | 将焦点列移动到侧面的显示器 |
| <kbd>Mod</kbd><kbd>U</kbd> 或 <kbd>Mod</kbd><kbd>PageDown</kbd> | 切换到下方的工作区|
| <kbd>Mod</kbd><kbd>I</kbd> 或 <kbd>Mod</kbd><kbd>PageUp</kbd> | 切换到上方的工作区 |
| <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>U</kbd> 或 <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>PageDown</kbd> | 将焦点列移动到下方的工作区 |
| <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>I</kbd> 或 <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>PageUp</kbd> | 将焦点列移动到上方的工作区 |
| <kbd>Mod</kbd><kbd>Shift</kbd><kbd>U</kbd> 或 <kbd>Mod</kbd><kbd>Shift</kbd><kbd>PageDown</kbd> | 将焦点工作区向下移动 |
| <kbd>Mod</kbd><kbd>Shift</kbd><kbd>I</kbd> 或 <kbd>Mod</kbd><kbd>Shift</kbd><kbd>PageUp</kbd> | 将焦点工作区向上移动 |
| <kbd>Mod</kbd><kbd>,</kbd> | 将右侧的窗口合并到焦点列 |
| <kbd>Mod</kbd><kbd>.</kbd> | 将焦点列底部的窗口弹出为独立列 |
| <kbd>Mod</kbd><kbd>[</kbd> | 将焦点窗口向左合并或弹出 |
| <kbd>Mod</kbd><kbd>]</kbd> | 将焦点窗口向右合并或弹出 |
| <kbd>Mod</kbd><kbd>R</kbd> | 在预设列的宽度之间切换 |
| <kbd>Mod</kbd><kbd>Shift</kbd><kbd>R</kbd> | 在预设列的高度之间切换 |
| <kbd>Mod</kbd><kbd>F</kbd> | 最大化列 |
| <kbd>Mod</kbd><kbd>C</kbd> | 在视图中居中列 |
| <kbd>Mod</kbd><kbd>-</kbd> | 将列宽减少 10% |
| <kbd>Mod</kbd><kbd>=</kbd> | 将列宽增加 10% |
| <kbd>Mod</kbd><kbd>Shift</kbd><kbd>-</kbd> | 将窗口高度减少 10% |
| <kbd>Mod</kbd><kbd>Shift</kbd><kbd>=</kbd> | 将窗口高度增加 10% |
| <kbd>Mod</kbd><kbd>Ctrl</kbd><kbd>R</kbd> | 将窗口高度重置为自动 |
| <kbd>Mod</kbd><kbd>Shift</kbd><kbd>F</kbd> | 切换焦点窗口的全屏状态 |
| <kbd>Mod</kbd><kbd>V</kbd> | 将焦点窗口在浮动和平铺布局之间移动 |
| <kbd>Mod</kbd><kbd>Shift</kbd><kbd>V</kbd> | 在浮动和平铺布局之间切换焦点 |
| <kbd>PrtSc</kbd> | 截取区域截图。使用鼠标选择要截图的区域，然后按 空格 保存截图，或按 Esc 取消 |
| <kbd>Alt</kbd><kbd>PrtSc</kbd> | 将焦点窗口截图到剪贴板和 `~/Pictures/Screenshots/` |
| <kbd>Ctrl</kbd><kbd>PrtSc</kbd> | 将焦点显示器截图到剪贴板和 `~/Pictures/Screenshots/` |
| <kbd>Mod</kbd><kbd>Shift</kbd><kbd>E</kbd> 或 <kbd>Ctrl</kbd><kbd>Alt</kbd><kbd>Delete</kbd> | 退出 niri |

## 构建 {#build}

首先，安装您的发行版的依赖项。

- Ubuntu 24.04:

    ```sh
    sudo apt-get install -y gcc clang libudev-dev libgbm-dev libxkbcommon-dev libegl1-mesa-dev libwayland-dev libinput-dev libdbus-1-dev libsystemd-dev libseat-dev libpipewire-0.3-dev libpango1.0-dev libdisplay-info-dev
    ```

- Fedora:

    ```sh
    sudo dnf install gcc libudev-devel libgbm-devel libxkbcommon-devel wayland-devel libinput-devel dbus-devel systemd-devel libseat-devel pipewire-devel pango-devel cairo-gobject-devel clang libdisplay-info-devel
    ```

接下来，获取最新的稳定版 Rust：https://rustup.rs/

然后，使用 `cargo build --release` 构建 niri。

查看 Cargo.toml 了解构建功能列表。
例如，您可以使用 `cargo build --release --no-default-features --features dinit,dbus,xdp-gnome-screencast` 将 systemd 集成替换为 dinit 集成。

> [!WARNING]
> 不要使用 `--all-features` 构建！
>
> 某些功能仅供开发调试使用。
> 例如，其中一项功能会将性能分析数据不断写入内存缓冲区中，直到耗尽所有内存。

### NixOS/Nix

我们有一个社区维护的 flake，它提供了包含所需依赖项的 devshell。使用 `nix build` 构建 niri，然后运行 `./results/bin/niri`。

如果您不在 NixOS 上，可能需要 [NixGL](https://github.com/nix-community/nixGL) 来运行生成的二进制文件：

```sh
nix run --impure github:guibou/nixGL -- ./results/bin/niri
```

### 手动安装 {#manual-installation}

如果直接安装而不使用包管理，推荐的目标文件位置会略有不同。
在这种情况下，请将文件放入下表所示的目录中。
具体位置可能因发行版而异。

不要忘记确保 niri.service 中 `niri` 的路径是正确的。
默认为 `/usr/bin/niri`。

| 文件 | 目标位置 |
| ---- | ----------- |
| `target/release/niri` | `/usr/local/bin/` |
| `resources/niri-session` | `/usr/local/bin/` |
| `resources/niri.desktop`  | `/usr/local/share/wayland-sessions/` |
| `resources/niri-portals.conf` | `/usr/local/share/xdg-desktop-portal/` |
| `resources/niri.service` (systemd) | `/etc/systemd/user/` |
| `resources/niri-shutdown.target` (systemd) | `/etc/systemd/user/` |
| `resources/dinit/niri` (dinit) | `/etc/dinit.d/user/` |
| `resources/dinit/niri-shutdown` (dinit) | `/etc/dinit.d/user/` |

[Alacritty]: https://github.com/alacritty/alacritty
[fuzzel]: https://codeberg.org/dnkl/fuzzel
