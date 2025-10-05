### 高显存占用修复

目前，NVIDIA 驱动中存在一个怪异问题，它会影响 niri 的显存占用情况（驱动无法正确将显存释放回资源池）。Niri *理应* 使用大约 100 MiB 的显存（可通过 [nvtop](https://github.com/Syllo/nvtop) 查验）；如果您观察到占用的显存量接近 1 GiB，则很可能遇到了这个问题（堆内存未将已释放的缓冲区返还给驱动）。

好在您可以通过为 NVIDIA 驱动配置进程级应用配置文件来缓解此问题，方法如下：

* 如果配置目录不存在（如果您正在阅读本文，则很可能不存在），请运行 `sudo mkdir -p /etc/nvidia/nvidia-application-profiles-rc.d` 来创建它
* 将以下 JSON 内容写入 `/etc/nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json` 文件，为 `niri` 进程设置 `GLVidHeapReuseRatio` 参数：

    ```json
    {
        "rules": [
            {
                "pattern": {
                    "feature": "procname",
                    "matches": "niri"
                },
                "profile": "Limit Free Buffer Pool On Wayland Compositors"
            }
        ],
        "profiles": [
            {
                "name": "Limit Free Buffer Pool On Wayland Compositors",
                "settings": [
                    {
                        "key": "GLVidHeapReuseRatio",
                        "value": 0
                    }
                ]
            }
        ]
    }
    ```

    （`/etc/nvidia/nvidia-application-profiles-rc.d/` 目录下的文件可以任意命名，实际上不需要扩展名）。

写入配置文件后请重启 niri 以应用更改。

此解决方案源自上游问题的讨论，位于[此处](https://github.com/NVIDIA/egl-wayland/issues/126#issuecomment-2379945259)。NVIDIA 有（微小的）可能更新其内置的应用程序配置文件，以自动为 niri 应用此设置；但底层启发式算法获得根本性修复的可能性较低。

在撰写本文时，驱动程序中提供的修复方案采用参数值 0，而大约一年前由 Nvidia 工程师发布的初始配置使用的参数值为 1。

### 屏幕录制闪烁修复

<sup>Until: 25.08</sup>

如果您在 NVIDIA 设备上遇到屏幕录制画面异常或闪烁，请在 niri 配置中设置以下内容：

```kdl,must-fail
debug {
    wait-for-frame-completion-in-pipewire
}
```

由于该问题已在 niri 中得到彻底修复，此调试标志现已被移除。
