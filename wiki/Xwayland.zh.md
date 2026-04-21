## 使用 xwayland-satellite

<sup>Since: 25.08</sup> Niri 原生支持了 [xwayland-satellite](https://github.com/Supreeeme/xwayland-satellite)。
请确保已安装 xwayland-satellite >= 0.7 并且它可以在 `$PATH` 中被调用。
无需进一步配置，niri 会在磁盘上创建 X11 套接字，导出 `$DISPLAY`，并在有 X11 客户端连接时按需启动 xwayland-satellite。
如果 xwayland-satellite 崩溃，niri 将会自动重启它。

如果您在某个自定义配置中，手动启动了 `xwayland-satellite` 并设置了 `$DISPLAY`，您应该移除这些自定义配置，以便自动集成能够正常工作。

要验证集成是否正常工作，请查验 niri 的输出是否包含类似 `listening on X11 socket: :0` 的内容：

```sh
$ journalctl --user-unit=niri -b
systemd[2338]: Starting niri.service - A scrollable-tiling Wayland compositor...
niri[2474]: 2025-08-29T04:07:40.043402Z  INFO niri: starting version 25.05.1 (0.0.git.2345.d9833fc1)
(...)
niri[2474]: 2025-08-29T04:07:40.690512Z  INFO niri: listening on Wayland socket: wayland-1
niri[2474]: 2025-08-29T04:07:40.690520Z  INFO niri: IPC listening on: /run/user/1000/niri.wayland-1.2474.sock
niri[2474]: 2025-08-29T04:07:40.700137Z  INFO niri: listening on X11 socket: :0
systemd[2338]: Started niri.service - A scrollable-tiling Wayland compositor.
$ echo $DISPLAY
:0
```

![xwayland-satellite 运行着 Steam 和 Half-Life。](https://github.com/user-attachments/assets/57db8f96-40d4-4621-a389-373c169349a4)

我们选择使用 xwayland-satellite 而非直接集成 Xwayland，是因为 [X11 非常诡异](./FAQ.md#why-doesnt-niri-integrate-xwayland-like-other-compositors)。
xwayland-satellite 为我们承担了处理 X11 各种特性的主要工作，最终提供给 niri 正常的 Wayland 窗口进行管理。

xwayland-satellite 与大多数应用程序的兼容良好：Steam、各类游戏、Discord，甚至包括使用 wine Windows VST 插件的 Ardour 这种更特殊的应用。
然而，那些想要将窗口或栏定位在特定屏幕坐标的 X11 应用程序将无法正确运行，它们需要在一个嵌套的合成器中运行。
请参阅下面的章节了解如何操作。

## 使用 labwc Wayland 合成器

[Labwc](https://github.com/labwc/labwc) 是一款支持 Xwayland 的传统堆叠式 Wayland 合成器。
您可以将其作为一个窗口在 niri 中运行，然后在其中启动 X11 应用程序。

1. 从您的发行版包管理器中安装 labwc。
1. 在 niri 中通过 `labwc` 命令运行它。
它将作为一个新窗口打开。
1. 在它提供的 X11 DISPLAY 上运行一个 X11 应用程序，例如： `env DISPLAY=:0 glxgears`

![Labwc 运行 X11 应用程序。](https://github.com/user-attachments/assets/aecbcecb-f0cb-4909-867f-09d34b5a2d7e)

## 在 rootful 模式下直接运行 Xwayland

此方法涉及直接调用 XWayland 并将其作为一个独立的窗口运行，同时还需要在 Xwayland 内部额外运行一个 X11 窗口管理器。

![Xwayland 在 rootful 模式下运行。](https://github.com/YaLTeR/niri/assets/1794388/b64e96c4-a0bb-4316-94a0-ff445d4c7da7)

操作步骤如下：

1. 运行 `Xwayland`（只需单独运行该二进制文件，无需附加任何参数）。
这将启动一个黑色窗口，为了方便，您可以调整其大小或全屏显示（使用 Mod+Shift+F）。
在旧版本的 Xwayland 上，窗口将是全屏的且不可调整大小。
1. 在该 Xwayland 实例中运行某个 X11 窗口管理器，例如 `env DISPLAY=:0 i3`。
这样您就可以管理在 Xwayland 实例内的 X11 窗口。
1. 在其中运行一个 X11 应用程序，例如 `env DISPLAY=:0 flatpak run com.valvesoftware.Steam`。

在全屏 Xwayland 中运行全屏游戏，您将获得近乎正常的游戏体验。

> [!TIP]
> 如果您不运行 X11 窗口管理器，那么当所有 X11 窗口都关闭后，再有新的 X11 窗口打开时，Xwayland 会关闭并重新打开其窗口。
> 为避免这种情况发生，请按照上述方法在内部启动一个 X11 WM，或者打开某个长时间运行的 X11 窗口。

一个需要注意的点是，目前 rootful Xwayland 似乎无法与合成器共享剪贴板。
对于文本数据，您可以使用 [wl-clipboard](https://github.com/bugaevc/wl-clipboard) 来手动实现，例如：

- `env DISPLAY=:0 xsel -ob | wl-copy` 将文本从 Xwayland 复制到 niri 剪贴板
- `wl-paste -n | env DISPLAY=:0 xsel -ib` 将文本从 niri 复制到 Xwayland 剪贴板

如果您需要，还可以将这些命令绑定到快捷键：

```
binds {
    Mod+Shift+C { spawn "sh" "-c" "env DISPLAY=:0 xsel -ob | wl-copy"; }
    Mod+Shift+V { spawn "sh" "-c" "wl-paste -n | env DISPLAY=:0 xsel -ib"; }
}
```

## 使用 xwayland-run 运行 Xwayland

[xwayland-run] 是一个辅助工具，用于在专用的 Xwayland rootful 服务器中运行 X11 客户端。
它会负责启动 Xwayland，设置 X11 DISPLAY 环境变量，设置 xauth，并使用新启动的 Xwayland 实例运行指定的 X11 客户端。
当 X11 客户端退出时，xwayland-run 将自动关闭专用的 Xwayland 服务器。

使用方法如下：

```
xwayland-run <Xwayland 参数> -- your-x11-app <X11 应用参数>
```

例如：

```
xwayland-run -geometry 800x600 -fullscreen -- wine wingame.exe
```

## 使用 Cage Wayland 合成器

也可以在 [Cage](https://github.com/cage-kiosk/cage) 中运行 X11 应用程序，它会运行一个嵌套的 Wayland 会话，该会话同样支持 Xwayland，X11 应用程序可以在其中运行。

与 Xwayland rootful 方法相比，此方法不需要运行额外的 X11 窗口管理器，并且可以通过一条命令 `cage -- /path/to/application` 来使用。但是，如果在 Cage 内部启动多个窗口，也可能会引发问题，因为 Cage 是为信息亭模式设计的，每个新窗口都会自动全屏并覆盖先前打开的窗口。

要使用 Cage，您需要：

1. 安装 `cage`，大多数软件仓库中应该都包含此包。
2. 运行 `cage -- /path/to/application`，即可在 niri 上享受您的 X11 程序。

或者，您也还可以修改应用程序的桌面快捷方式，在 `Exec` 属性中添加 `cage --` 前缀。例如 Spotify Flatpak 的桌面快捷方式可以修改为如下所示：

```ini
[Desktop Entry]
Type=Application
Name=Spotify
GenericName=Online music streaming service
Comment=Access all of your favorite music
Icon=com.spotify.Client
Exec=cage -- flatpak run com.spotify.Client
Terminal=false
```

## Proton-GE 原生 Wayland

有些游戏可以作为原生 Wayland 客户端运行，从而规避与 X11 相关的问题。您可以使用像[Proton-GE](https://github.com/GloriousEggroll/proton-ge-custom)这样的自定义 Proton 版本，并在游戏的启动参数中设置 `PROTON_ENABLE_WAYLAND=1` 环境变量来实现。请注意，目前这仍是一个实验性功能，可能不适用于所有游戏，并且可能其自身也存在问题。

```
PROTON_ENABLE_WAYLAND=1 %command%
```

## 使用 gamescope

您可以使用 [gamescope](https://github.com/ValveSoftware/gamescope) 来运行 X11 游戏甚至是 Steam 本身。

与 Cage 类似，gamescope 只会显示单个最顶层的窗口，因此不太适合运行常规应用程序。
但是您可以在 gamescope 中运行 Steam，然后从 Steam 中启动游戏，这样是没问题的。

```
gamescope -- flatpak run com.valvesoftware.Steam
```

若要以全屏模式运行 gamescope，您可以传递设置必要分辨率的参数，以及以全屏模式启动的参数：

```
gamescope -W 2560 -H 1440 -w 2560 -h 1440 -f  -- flatpak run com.valvesoftware.Steam
```

> [!NOTE]
> 如果 Steam 在 gamescope 中异常终止，后续的 gamescope 调用有时会无法正常启动它。
> 如果发生这种情况，请按照上述方法，在 rootful Xwayland 中运行 Steam，然后正常退出 Steam，之后您就可以再次使用 gamescope 了。

[xwayland-run]: https://gitlab.freedesktop.org/ofourdan/xwayland-run
[xwayland-satellite]: https://github.com/Supreeeme/xwayland-satellite
