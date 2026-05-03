niri 认为在宿主机上以非沙盒方式运行的程序是**受信任的**。

这是一个合理的假设，因为即使在缺少 niri 的情况下，运行在宿主机上的程序也可以通过多种方式获得所需的全部访问权限。
例如：

- 可以在 `.bashrc` 或类似文件中设置 `$LD_PRELOAD`，向所有进程中加载任意库。
- 可以将 `$PATH` 中的二进制文件替换为恶意代码。
- 可以拦截 `$XDG_RUNTIME_DIR` 中的任何套接字（例如 Wayland），从而进行键盘记录或录制窗口内容。
- 可以扫描文件系统以查找机密信息：SSH 密钥、密码存储等。
- 可以连接到已解锁的密钥环并窃取凭据。
- 诸如此类，不胜枚举。

## 非沙盒客户端

任何能够访问 niri 的 Wayland 套接字的程序，可以执行以下操作（包括但不限于）：

- 通过 [wlr-screencopy](https://wayland.app/protocols/wlr-screencopy-unstable-v1) 录制用户屏幕。
- 通过 [wlr-virtual-pointer](https://wayland.app/protocols/wlr-virtual-pointer-unstable-v1) 和 [virtual-keyboard](https://wayland.app/protocols/virtual-keyboard-unstable-v1) 模拟输入。
- 通过 [wlr-data-control](https://wayland.app/protocols/ext-data-control-v1) 获取用户的剪贴板内容。
- 通过 [wlr-layer-shell](https://wayland.app/protocols/wlr-layer-shell-unstable-v1) 创建任意全屏表面，可以窃取用户输入、伪装成密码输入界面或将用户锁定在会话之外。
- 终止正在运行的锁屏程序，创建新的锁屏界面，并通知 niri 解锁已锁定的会话。

任何能够访问 niri 的 [IPC](./IPC.md) 套接字的程序，可以执行以下操作（包括但不限于）：

- 生成一个 Wayland 客户端，而该客户端可以执行上述列表中的所有操作。

任何能够访问 niri 的 D-Bus 接口的程序，可以执行以下操作（包括但不限于）：

- 通过屏幕录制接口录制用户屏幕。
- 通过无障碍接口完全监听并模拟来自用户键盘的输入。

此外，虽然 niri 并未直接集成 Xwayland，但值得一提的是：任何能够访问 X11 `$DISPLAY`（它既作为磁盘上的套接字文件**也**作为网络命名空间中的抽象套接字存在）的程序，都可以拦截并模拟同一 `$DISPLAY` 下所有 X11 窗口的全部输入，并录制其内容（但无法录制 Wayland 窗口）。

## 运行不受信任的客户端

考虑到以上所有情况，要运行不受信任的客户端，需要具备一个适当的沙盒环境：

- 移除 niri 的 IPC 套接字。
- 阻止对宿主机服务的 D-Bus 访问。
- 使用经过过滤的 Wayland 套接字。

要创建经过过滤的 Wayland 套接字，可以使用 niri 所实现的 [security-context](https://wayland.app/protocols/security-context-v1) 协议。
通过这个过滤后的 Wayland 套接字，所有不安全的协议都将无法访问。

有一个满足以上所有条件的沙盒方案是 [Flatpak](https://flatpak.org/) 沙盒。

需要注意的是，仅仅过滤 Wayland 套接字（而保留例如不受限制的 D-Bus 访问）**不足以免受**不受信任的客户端执行恶意操作。

## 锁屏

当会话通过 [ext-session-lock](https://wayland.app/protocols/ext-session-lock-v1) 锁定后，大部分操作（按键绑定）将被自动禁用。
仅允许执行一小部分安全操作。
特别地，生成（spawn）操作将不可用，但显式配置了 `allow-when-locked=true` 的绑定除外。

需要注意的是，**退出**操作是被允许的——即使处于锁屏状态，你也可以随时退出 niri。
因此，你必须确保退出 niri 不会将你置入一个不受保护的 TTY 命令行环境。
通常，显示管理器（例如 GDM）会为你处理这个问题：当 niri 退出时（无论是通过退出绑定还是崩溃），它会将你带回到一个安全的密码提示界面。

除了退出之外，离开锁屏的唯一方式是由锁屏客户端通知 niri 解锁会话。
如果锁屏客户端崩溃，会话将保持锁定状态，并显示纯红色背景。
在这种情况下，另一个锁屏客户端可以接管（因此，如果原锁屏客户端崩溃，你可以启动一个新的锁屏客户端，并仍然能够解锁你的会话）。
