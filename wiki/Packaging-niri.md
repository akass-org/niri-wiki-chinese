### 概述

在构建 niri 时，请查阅 `Cargo.toml` 以了解构建特性列表。
例如，您可以使用 `cargo build --release --no-default-features --features dinit,dbus,xdp-gnome-screencast` 将 systemd 集成替换为 dinit 集成。
不过，默认特性应该适用于大多数发行版。

> [!WARNING]
> 请 不要 使用 `--all-features` 构建！
>
> 某些特性仅供开发使用。
> 例如，其中一个特性会启用性能分析数据的收集，数据会被存入一个内存缓冲区，并无限增长，直至耗尽所有内存。

`niri-visual-tests` 这个 sub-crate/二进制文件 仅供开发使用，不应被打包。

推荐将 niri 打包为独立的桌面会话运行。
为此，请根据下表将文件放入正确的目录中。

| 文件 | 目标路径 |
| ---- | ----------- |
| `target/release/niri` | `/usr/bin/` |
| `resources/niri-session` | `/usr/bin/` |
| `resources/niri.desktop` | `/usr/share/wayland-sessions/` |
| `resources/niri-portals.conf` | `/usr/share/xdg-desktop-portal/` |
| `resources/niri.service` (systemd) | `/usr/lib/systemd/user/` |
| `resources/niri-shutdown.target` (systemd) | `/usr/lib/systemd/user/` |
| `resources/dinit/niri` (dinit) | `/usr/lib/dinit.d/user/` |
| `resources/dinit/niri-shutdown` (dinit) | `/usr/lib/dinit.d/user/` |

这样做将使 niri 出现在 GDM 和其他显示管理器的会话选择中。

有关发行版集成的更多信息，请参阅 [集成 niri](./Integrating-niri.md) 页面。

### 运行测试

我们的大部分测试会启动 niri 合成器实例并测试 Wayland 客户端。
这不需要图形会话，但由于测试并行性，在核心数较多的系统上可能会遇到文件描述符限制。

如果您遇到此问题，您可能不仅需要限制 Rust 测试工具的线程数，还需要限制 Rayon 的线程数，因为某些 niri 测试使用了内部的 Rayon 线程：

```
$ export RAYON_NUM_THREADS=2
...然后运行 cargo test，或许可以加上 --test-threads=2
```

运行测试时，别忘了排除仅供开发使用的 `niri-visual-tests` crate。

某些测试要求在测试时系统中已提供无界面 EGL 支持。
如果这有问题，您可以像这样跳过它们：

```
$ cargo test -- --skip=::egl
```

您可能还需要设置环境变量 `RUN_SLOW_TESTS=1` 来运行较慢的测试。

### 版本字符串

niri 版本字符串包含其版本号和提交哈希：

```
$ niri --version
niri 25.01 (e35c630)
```

在打包系统中构建时，通常没有代码仓库，因此无法获取提交哈希，版本将显示为 "unknown commit"。
在这种情况下，请手动设置提交哈希：

```
$ export NIRI_BUILD_COMMIT="e35c630"
...然后继续构建 niri
```

您也可以完全覆盖版本字符串，在这种情况下，请确保相应的 niri 版本信息保持完整：

```
$ export NIRI_BUILD_VERSION_STRING="25.01-1 (e35c630)"
...然后继续构建 niri
```

请记住，对于 `cargo build` 和 `cargo install` 都要设置此环境变量，因为如果环境发生变化，后者将会重新构建 niri。

### 崩溃回溯（Panics）

清晰刻度可读的崩溃（panic）回溯对于诊断 niri 崩溃（crash）至关重要。
请使用 `niri panic` 命令来测试您的软件包是否能生成良好的回溯信息。

```
$ niri panic
thread 'main' panicked at /builddir/build/BUILD/rust-1.83.0-build/rustc-1.83.0-src/library/core/src/time.rs:1142:31:
overflow when subtracting durations
stack backtrace:
   0: rust_begin_unwind
             at /builddir/build/BUILD/rust-1.83.0-build/rustc-1.83.0-src/library/std/src/panicking.rs:665:5
   1: core::panicking::panic_fmt
             at /builddir/build/BUILD/rust-1.83.0-build/rustc-1.83.0-src/library/core/src/panicking.rs:74:14
   2: core::panicking::panic_display
             at /builddir/build/BUILD/rust-1.83.0-build/rustc-1.83.0-src/library/core/src/panicking.rs:264:5
   3: core::option::expect_failed
             at /builddir/build/BUILD/rust-1.83.0-build/rustc-1.83.0-src/library/core/src/option.rs:2021:5
   4: expect<core::time::Duration>
             at /builddir/build/BUILD/rust-1.83.0-build/rustc-1.83.0-src/library/core/src/option.rs:933:21
   5: sub
             at /builddir/build/BUILD/rust-1.83.0-build/rustc-1.83.0-src/library/core/src/time.rs:1142:31
   6: cause_panic
             at /builddir/build/BUILD/niri-0.0.git.1699.279c8b6a-build/niri/src/utils/mod.rs:382:13
   7: main
             at /builddir/build/BUILD/niri-0.0.git.1699.279c8b6a-build/niri/src/main.rs:107:27
   8: call_once<fn() -> core::result::Result<(), alloc::boxed::Box<dyn core::error::Error, alloc::alloc::Global>>, ()>
             at /builddir/build/BUILD/rust-1.83.0-build/rustc-1.83.0-src/library/core/src/ops/function.rs:250:5
note: Some details are omitted, run with `RUST_BACKTRACE=full` for a verbose backtrace.
```

需要关注的重点事项：

- 崩溃消息存在：“减去持续时间时溢出（overflow when subtracting durations）”。
- 回溯一直追溯到 `main` 函数，并包含 `cause_panic`。
- 回溯包含 `cause_panic` 的文件和行号信息：`at /.../src/utils/mod.rs:382:13`。

如果可以的话，请确保您的 niri 软件包本身具有良好的崩溃回溯，即*无需*安装调试信息或其他包。
当用户的合成器首次崩溃时，他们很可能没有安装 debuginfo，而我们非常希望能够立即诊断并修复所有崩溃。

### Rust 依赖项

每个 niri 版本都附带一个通过 `cargo vendor` 生成的依赖项归档文件。
您可以使用它来完全离线地构建相应的 niri 版本。

如果您不想使用打包的依赖项，请考虑遵循 niri 发布版本中的 `Cargo.lock`。
它包含了我在测试该发布版本时使用的确切依赖版本。

如果您需要更改某些依赖项的版本，请特别注意 `smithay` 和 `smithay-drm-extras` 的提交哈希。
这些 crate 目前没有定期的稳定版本发布，因此 niri 使用 git 快照。
上游经常有破坏性变更（API 和行为），因此强烈建议您使用 niri 发布版本 `Cargo.lock` 中的确切提交哈希。

### Shell 自动补全

您可以通过 `niri completions <SHELL>` 为多个 shell 生成自动补全脚本，例如 `niri completions bash`。
完整列表请参见 `niri completions -h`。
