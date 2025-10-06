当从 GDM 等显示管理器启动 niri，或通过 `niri-session` 二进制文件启动时，它会作为 systemd 服务运行。
这提供了必要的 systemd 集成，用于运行绑定到图形会话的程序（如 `mako`）和服务（如 `xdg-desktop-portal`）。

以下是如何将 [`mako`](https://github.com/emersion/mako)、[`waybar`](https://github.com/Alexays/Waybar)、[`swaybg`](https://github.com/swaywm/swaybg) 和 [`swayidle`](https://github.com/swaywm/swayidle) 设置为与 niri 一起作为 systemd 服务运行的示例。
与 [`spawn-at-startup`](./Configuration:-Miscellaneous.md#spawn-at-startup) 不同，这使您可以轻松监控它们的状态和输出，并重新启动或重新加载它们。

1. 安装它们，例如 `sudo dnf install mako waybar swaybg swayidle`
2. `mako` 和 `waybar` 开箱即用地提供 systemd 单元，因此您可以简单地将它们添加到 niri 会话中：

    ```
    systemctl --user add-wants niri.service mako.service
    systemctl --user add-wants niri.service waybar.service
    ```

    这将在 `~/.config/systemd/user/niri.service.wants/` 目录中创建链接，这是一个特殊的 systemd 文件夹，用于需要与 `niri.service` 一起启动的服务。

3. `swaybg` 不提供 systemd 单元，因为您需要将背景图像作为命令行参数传递。
    因此，我们将自己创建一个。
    使用以下内容创建 `~/.config/systemd/user/swaybg.service`：

    ```systemd
    [Unit]
    PartOf=graphical-session.target
    After=graphical-session.target
    Requisite=graphical-session.target

    [Service]
    ExecStart=/usr/bin/swaybg -m fill -i "%h/Pictures/LakeSide.png"
    Restart=on-failure
    ```

    将图像路径替换为您想要的路径。
    `%h` 会被展开为您的主（home）目录路径。

    在编辑 `swaybg.service` 后，运行 `systemctl --user daemon-reload` 以便 systemd 获取文件中的更改。

    现在，将其添加到 niri 会话中：

    ```
    systemctl --user add-wants niri.service swaybg.service
    ```

4. `swayidle` 同样不提供 service，因此我们也需要自己创建一个。
    使用以下内容创建 `~/.config/systemd/user/swayidle.service`：

    ```systemd
    [Unit]
    PartOf=graphical-session.target
    After=graphical-session.target
    Requisite=graphical-session.target

    [Service]
    ExecStart=/usr/bin/swayidle -w timeout 601 'niri msg action power-off-monitors' timeout 600 'swaylock -f' before-sleep 'swaylock -f'
    Restart=on-failure
    ```

    然后，运行 `systemctl --user daemon-reload` ，并将其添加到 niri 会话中：

    ```
    systemctl --user add-wants niri.service swayidle.service
    ```

就是这样！
现在这三个工具将与 niri 会话一起启动，并在退出时停止。
您还可以在编辑其配置文件后，使用类似 `systemctl --user restart waybar.service` 的命令重启它们。

要从 niri 的启动中移除某个服务，只要将其符号链接从 `~/.config/systemd/user/niri.service.wants/` 目录中移除。然后运行 `systemctl --user daemon-reload` 即可。

### 在注销后运行程序

当把 niri 作为会话运行时，退出它（注销）将终止您在其中启动的所有程序。但是，有时候您希望某个程序（如 `tmux`、`dtach` 之类的）在注销后仍然保持运行。为此，可以把它放到一个临时的 systemd scope 中运行：

```
systemd-run --user --scope tmux new-session
```
