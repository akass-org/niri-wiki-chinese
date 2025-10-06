本页面包含有助于在发行版中集成 niri 的各种信息。
首先，关于创建 niri 软件包，请参阅 [打包](./Packaging-niri.md) 页面。

### 配置

Niri 将从 `$XDG_CONFIG_HOME/niri/config.kdl` 或 `~/.config/niri/config.kdl` 加载配置，如果这两个文件都不存在，则会回退到 `/etc/niri/config.kdl`。
如果这两个文件都缺失，niri 将使用在构建时已嵌入到 niri 二进制文件中的 [默认配置文件](https://github.com/YaLTeR/niri/blob/main/resources/default-config.kdl) 的内容创建 `$XDG_CONFIG_HOME/niri/config.kdl`容。

这意味着您可以通过创建 `/etc/niri/config.kdl` 来自定义您的发行版的默认设置。
当此文件存在时，niri *不会* 自动在 `~/.config/niri/` 创建配置文件，因此您需要指导用户如何自行创建。

请注意，我们会在新版本中更新默认配置，因此如果您有自定义的 `/etc/niri/config.kdl`，您可能也需要检查并应用相关的更改。

目前尚不支持将 niri 配置文件拆分为多个文件或使用包含（includes）指令。

### Xwayland

Xwayland 是运行 X11 应用程序和游戏以及 Orca 屏幕阅读器所必需的。

<sup>Since: 25.08</sup>  Niri 已内建了对 [xwayland-satellite](https://github.com/Supreeeme/xwayland-satellite) 的自动集成。
该集成要求 `$PATH` 中有可用的 xwayland-satellite >= 0.7。
请考虑让 niri 依赖于（或至少建议）xwayland-satellite 软件包。
如果您曾通过自定义配置手动启动 `xwayland-satellite` 并设置 `$DISPLAY`，请移除这些自定义项，以便自动集成功能正常工作。

您可以使用 [`xwayland-satellite` 顶层配置选项](./Configuration:-Miscellaneous.md#xwayland-satellite) 来更改 niri 查找 xwayland-satellite 的路径。

### 键盘布局

<sup>Since: 25.08</sup> 默认情况下（除非[手动配置](./Configuration:-Input.md#layout)），niri 会通过 D-Bus 从 systemd-localed 的 `org.freedesktop.locale1` 读取键盘布局设置。
请确保您的系统安装程序通过 systemd-localed 设置键盘布局，niri 应该会自动获取该设置。

### 自启动

Niri 与标准的 systemd 自启动机制兼容。
默认的 [niri.service](https://github.com/YaLTeR/niri/blob/main/resources/niri.service) 会启动 `graphical-session.target` 以及 `xdg-desktop-autostart.target`。

若要在不编辑 niri 配置的情况下让程序在 niri 启动时运行，您可以将程序的 .desktop 文件链接到 `~/.config/autostart/`，或使用带有 `WantedBy=graphical-session.target` 的 .service 文件。
有关示例，请参阅[systemd 服务配置示例](./Example-systemd-Setup.md)页面。

如果这种方式不方便，您也可以在 niri 配置中添加 [`spawn-at-startup`](./Configuration:-Miscellaneous.md#spawn-at-startup) 行。

### 屏幕阅读器

<sup>Since: 25.08</sup> Niri 与 [Orca](https://orca.gnome.org) 屏幕阅读器是兼容的。
有关详细信息以及对专注于无障碍功能的发行版的建议，，请参阅[无障碍](./Accessibility.md)页面。

### 桌面组件

您很可能至少需要运行一个通知守护程序、portal 组件和一个身份验证代理。
详细信息请参阅[重要软件](./Important-Software.md)页面。

除此之外，您可能需要预配置一些桌面 shell 组件，以使体验不那么简陋。
Niri 的默认配置会启动 [Waybar](https://github.com/Alexays/Waybar)，这是一个很好的起点，但您可能需要考虑更改其默认配置，使其不那么“大杂烩”，并添加 `niri/workspaces` 模块。
您可能还需要一个桌面背景工具（[swaybg](https://github.com/swaywm/swaybg) 或 [swww](https://github.com/LGFae/swww)），以及一个比默认的 `swaylock` 更好的屏幕锁定程序，例如 [hyprlock](https://github.com/hyprwm/hyprlock/)。

另外，一些桌面环境和 shell 可以与 niri 协同工作，并提供一个更完整的打包体验：

- [LXQt](https://lxqt-project.org/) 官方支持 niri，有关设置详情，请参阅[他们的 wiki](https://github.com/lxqt/lxqt/wiki/ConfigWaylandSettings#general)。
- 许多 [XFCE](https://www.xfce.org/) 组件可以在 Wayland 上运行，包括 niri。有关详情，请参阅[他们的 wiki](https://wiki.xfce.org/releng/wayland_roadmap#component_specific_status)。
- 有一些基于 Quickshell 的完整桌面 shell 支持 niri，例如 [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) 和 [Noctalia](https://github.com/noctalia-dev/noctalia-shell)。
- 您可以使用 [cosmic-ext-extra-sessions](https://github.com/Drakulix/cosmic-ext-extra-sessions) 在 niri 上运行 [COSMIC](https://system76.com/cosmic/) 会话。
