由于 niri 不是一个完整的桌面环境，您很可能需要运行以下软件以确保其他应用程序能正常工作。

### 通知守护进程

许多应用程序需要它。例如，[mako](https://github.com/emersion/mako) 运行良好。请使用 [systemd 设置](./Example-systemd-Setup.md) 或 [`spawn-at-startup`](./Configuration:-Miscellaneous.md#spawn-at-startup)。

### Portals

这些为应用程序提供了一个跨桌面的 API，用于文件选择器或 UI 设置等各种功能。特别是 Flatpak 应用程序需要正常工作的 portals。

Portals **要求** [将 niri 作为会话运行](./Getting-Started.md)，这意味着通过 `niri-session` 脚本或显示管理器启动。您需要安装以下 portals：

* `xdg-desktop-portal-gtk`：实现大多数基本功能，这是“默认回退 portal”。
* `xdg-desktop-portal-gnome`：支持屏幕录制所必需的。
* `gnome-keyring`：实现 Secret portal，某些应用程序需要它才能正常工作。

然后 systemd 应该会自动按需启动它们。这些特定的 portals 在 `niri-portals.conf` 中配置，该文件[必须安装](./Getting-Started.md#manual-installation)在正确的位置。

由于我们使用的是 `xdg-desktop-portal-gnome`，Flatpak 应用程序将读取 GNOME UI 设置。例如，要启用深色样式，请运行：

```
dconf write /org/gnome/desktop/interface/color-scheme '"prefer-dark"'
```

请注意，如果您使用提供的 `resources/niri-portals.conf`，还需要安装 `nautilus` 文件管理器，以便文件选择器对话框能正常工作。这是必要的，因为从 47.0 版本开始，xdg-desktop-portal-gnome 默认使用 nautilus 作为文件选择器。

如果您不想安装 `nautilus`（比如您使用的是 `nemo`），可以在 `niri-portals.conf` 中设置 `org.freedesktop.impl.portal.FileChooser=gtk;`，以便为文件选择器对话框使用 GTK portal。

### 认证代理

当应用程序需要请求 root 权限时需要它。类似 `plasma-polkit-agent` 的东西可以很好地工作。请使用 [systemd](./Example-systemd-Setup.md) 或 [`spawn-at-startup`](./Configuration:-Miscellaneous.md#spawn-at-startup) 启动它。

请注意，要在 Fedora 上使用 systemd 启动 `plasma-polkit-agent`，您需要覆盖其 systemd 服务以添加正确的依赖关系。请运行：

```
systemctl --user edit --full plasma-polkit-agent.service
```

然后添加 `After=graphical-session.target`。

### Xwayland

要运行 Steam 或 Discord 等 X11 应用程序，您可以使用 [xwayland-satellite]。
有关说明，请查看 [Xwayland wiki 页面](./Xwayland.md)。

[xwayland-satellite]: https://github.com/Supreeeme/xwayland-satellite
