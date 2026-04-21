## 运行本地构建

开发过程中测试 niri 的主要方法是将其作为嵌套窗口运行。第二步通常是切换到另一个 TTY 终端并在该终端上运行 niri。

当某个功能或修复基本完成后，通常需要运行本地构建版本作为主要合成器进行全面测试。最简单的方法是正常安装 niri（例如从发行版软件包安装），然后使用 `sudo cp ./target/release/niri /usr/bin/niri` 命令覆盖二进制文件。不过，请务必确保您知道如何回滚到之前的可用版本，以防出现问题。

如果你使用基于 RPM 的发行版，你可以使用 `cargo generate-rpm` 为本地构建生成 RPM 包。

## 日志等级

Niri 使用 [`tracing`](https://lib.rs/crates/tracing) 进行日志记录。以下是日志级别的使用方式：

- `error!`: 表示可恢复的编程错误或漏洞。这些通常是你在代码中会用 `unwrap()` 处理的那类情况。但在 Wayland 合成器中，如果程序崩溃会导致整个会话终止，所以只要有可能，就应当记录 `error!` 并尽量恢复运行。如果你在 Niri 的日志中看到 `ERROR`，那总是代表有 *bug*。
- `warn!`: 发生了一些不好但仍然*可能*的事情。告知用户他们操作有误，或者他们的硬件出现了异常，就属于此类。例如，配置解析错误应该用 `warn!` 来指示。
- `info!`: 与正常运行相关的最重要的消息。使用 `RUST_LOG=niri=info` 运行 niri 不应该让用户觉得日志太多、想关闭日志。
- `debug!`: 与正常运行相关的次要消息。隐藏 `debug!` 消息运行 niri 不应该对用户体验产生负面影响。
- `trace!`: 包含所有可能有助于调试但过于冗杂或性能消耗过大的信息。`trace!` 消息会在发布版本中被*剔除*掉。

## 测试

我们有一些单元测试，最主要的是针对布局代码和配置解析的测试。

当向布局添加新操作时，请将其添加到 `src/layout/mod.rs` 底部的 `Op` 枚举中（这将自动将其包含在随机测试中），如果适用，还应添加到下面的 `every_op` 数组中。

添加新的配置选项时，请将其包含在配置解析测试中。

### 运行测试

确保运行 `cargo test --all` 来运行子 crate 中的测试。

有些测试运行速度太慢，例如布局代码的随机测试，因此通常会被跳过。设置 `RUN_SLOW_TESTS` 变量即可运行这些测试：

```
env RUN_SLOW_TESTS=1 cargo test --all
```

通常，延长随机测试的运行时间也很有帮助，这样可以探索更多输入。您可以使用环境变量来控制这一点。以下是我通常在推送代码前运行测试的方式：

```
env RUN_SLOW_TESTS=1 PROPTEST_CASES=200000 PROPTEST_MAX_GLOBAL_REJECTS=200000 RUST_BACKTRACE=1 cargo test --release --all
```

### 可视化测试

`niri-visual-tests` 子 crate 是一个 GTK 应用程序，它运行硬编码的测试用例，以便您可以直观地检查它们是否看起来正确。它使用真实布局和渲染代码的模拟窗口。当涉及动画时，它特别有用。

## 性能分析

我们集成了 [Tracy](https://github.com/wolfpld/tracy) 分析器，您可以通过在构建 niri 时添加功能标志来启用它：

```
cargo build --release --features=profile-with-tracy-ondemand
```

然后你可以打开 Tracy（需要最新的稳定版本），并连接到正在运行的 niri 实例来收集性能分析数据。性能分析数据是“按需”收集的——也就是说，只有在 Tracy 连接时才会收集。如果你愿意，可以像这样运行 niri 构建作为你的主要合成器。

> [!NOTE]
> 如果您需要分析 niri 启动或 niri CLI 的性能，可以使用以下功能标志选择“始终开启”的性能分析：
>
> ```
> cargo build --release --features=profile-with-tracy
> ```
>
> 以这种方式编译时，niri 将**始终**收集性能分析数据，因此您不能将这样的构建作为您的主要合成器运行。

要在 Tracy 中显示 niri 函数，请按如下方式进行配置：

```rust
pub fn some_function() {
    let _span = tracy_client::span!("some_function");

    // Code of the function.
}
```

您还可以使用 `--features=profile-with-tracy-allocations` 启用 Rust 内存分配分析。
