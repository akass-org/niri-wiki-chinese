您可以通过 IPC 套接字（socket）与正在运行的 niri 实例进行通信。
请查看 `niri msg --help` 了解可用命令。

`--json` 参数会以 JSON 格式打印响应，而不是格式化后的文本。
例如，`niri msg --json outputs`。

> [!TIP]
> 如果在升级 niri 后从 `niri msg` 收到解析错误，请确保您已重启过 niri 服务本身。
> 您可能正在尝试使用较新版本的 `niri msg` 连接旧版本的 `niri` 合成器。

### 事件流

<sup>Since: 0.1.9</sup>

虽然大多数 niri IPC 请求会返回单次响应，但事件流请求会使 niri 持续向 IPC 连接推送事件，直到连接关闭。
这对于实现各种栏和指示器非常有用，它们可以在事件发生时立即更新，而无需持续轮询。

事件流 IPC 的设计理念是，首先为您提供完整的当前状态，然后推送对该状态的更新。
通过这种方式，您的状态就永远不会与 niri “失去同步”，您也不需要再发起任何其他 IPC 信息请求。

在合理的情况下，事件流状态更新具有原子性，但情况并非总是如此。
例如，某个窗口可能仍关联一个已被移除的工作区 ID。
如果相应的工作区已更改事件早于相应的窗口已更改事件到达，就可能发生这种情况。

要初步了解事件内容，请运行 `niri msg event-stream`。
不过，这更多是一个调试功能。
您可以通过 `niri msg --json event-stream` 或者手动连接到 niri 套接字并请求事件流来获取原始事件。

您可以在[此处](https://yalter.github.io/niri/niri_ipc/enum.Event.html)找到完整的事件列表及文档。

### 编程访问

`niri msg --json` 是对写入和读取套接字的简单封装。
在实现更复杂的脚本和模块时，建议您直接访问套接字。

连接到文件系统中位于 `$NIRI_SOCKET` 的 UNIX 域套接字。
将您的请求以 JSON 格式编码后单行写入，后跟一个换行符，或者在刷新后关闭连接的写入端。
同样以单行 JSON 格式读取回复。

您可以使用 `socat` 来测试与 niri 的直接通信：

```sh
$ socat STDIO "$NIRI_SOCKET"
"FocusedWindow"
{"Ok":{"FocusedWindow":{"id":12,"title":"t socat STDIO /run/u ~","app_id":"Alacritty","workspace_id":6,"is_focused":true}}}
```

回复是一个 `Ok` 或 `Err`，它包装了与您从 `niri msg --json` 获取的 JSON 对象一致。

对于更复杂的请求，您可以使用 `socat` 来查找 `niri msg` 如何格式化它们：

```sh
$ socat STDIO UNIX-LISTEN:temp.sock
# 然后，在另一个终端中：
$ env NIRI_SOCKET=./temp.sock niri msg action focus-workspace 2
# 随后， 在 socat 终端查看：
{"Action":{"FocusWorkspace":{"reference":{"Index":2}}}}
```

您可以在 [niri-ipc 子包文档](https://yalter.github.io/niri/niri_ipc/) 中找到所有可用的请求和响应类型。

### 向后兼容性

JSON 输出*应当*保持稳定，具体表现为：

- 不应重命名现有字段和枚举变量
- 不应移除现有的非可选字段

但是，新的字段和枚举变量会被添加，因此您应该在合理的情况下优雅地处理未知字段或变量。

格式化/人类可读的输出（即不带 `--json` 参数的输出）**不**被认为是稳定的。
对于脚本开发，请优先使用 JSON 输出，因为我保留对人类可读输出进行任何更改的权利。

`niri-ipc` sub-crate（与其他 niri sub-crate 一样）在 Rust semver 方面*不是* API 稳定的，而是跟随 niri 自身版本迭代。
特别提醒，新的结构体字段和枚举变量将会被添加。
