本文是发布 niri 新版本所需办理事项的检查清单。

我们将使用 `26.04` 作为示例的新版本号。
在制作补丁版本时，请附加补丁编号，例如 `26.04.1`。

## 准备发布说明

这通常需要花费几天的时间，请做好规划。

在此过程中，请同步检查以下内容：

- wiki 上所有新增内容是否都标注了"next release"，
- `README.md` 中是否有需要更新的地方。

## 提升版本号

我们采用 `年.月.补丁` 的版本命名方式。
如果月份中包含前导零，请从 crate 版本中将其去掉（这是 Cargo 的要求）。

你可以使用 [cargo-edit](https://github.com/killercup/cargo-edit) 提供的命令：

```
cargo set-version 26.4.0
```

然后，手动更新以下位置的版本号：

- `Cargo.toml` 中的 `[package.metadata.generate-rpm]`
- `niri-ipc/README.md` 中的依赖示例
- `niri-ipc/src/lib.rs` 中的依赖示例

对旧版本号进行全文搜索，以确保没有遗漏其他地方。

## 替换所有 "Since: next release" 提及项

对 `next release` 进行全文搜索，全部替换为新版本号。

## 构建、测试、推送并等待 CI 运行

运行所有测试：

```
RUN_SLOW_TESTS=1 cargo test --release --all
```

- 运行 `cargo package -p niri-ipc` 并确保其成功。
- 确保 CI 通过。
- 确保 niri-git COPR 构建通过。

## 在 GitHub Actions 上触发"Prepare release"工作流

将"Public version"输入设置为类似 `26.04` 的版本号。

此工作流将会：

- 执行一些发布前的检查，例如在 wiki 中搜索"next version"，
- 制作一份依赖库归档（vendored dependency archive），
- 使用该依赖库归档构建并测试 niri，
- 草稿化一个新的 GitHub release 并附带该归档。
它不会覆盖同名的已有草稿 release，因此发布说明是安全的。

确保工作流成功运行，并获取其生成的依赖库归档文件。

## 更新 niri COPR spec，更新 .spec.rpkg 中的许可证信息

你可以从 COPR 中[上一次构建](https://copr.fedorainfracloud.org/coprs/yalter/niri/builds/)的页面获取上一个 spec 文件。

- 将 `%global version` 更新为 `26.04`。
- 将 `%global commit` 更新为与发布提交对应的提交哈希。
可使用 `git rev-parse HEAD` 获取。
- 如果 `Release:` 数字大于 1，请将其重置为 1。

要运行测试构建，可以从上一步下载依赖库归档文件。
相应地取消/注释 `Source:` 和 `%autosetup` 行。

下载源文件：

```
spectool -g niri.spec
```

构建 RPM：

```
fedpkg --release 44 mockbuild
```

构建过程中，会打印出许可证列表。
请在 COPR spec 和 `niri.spec.rpkg` 中相应更新。

如果你需要更新 `niri.spec.rpkg`，并因此向 niri 仓库提交了新的提交，请记得再次更新 COPR spec 中的提交哈希。

请将 COPR spec 中为本地测试所做的所有临时修改还原。

## 创建并推送 release git tag

tag 以 `v` 开头：

```
git tag -am "v26.04 release" v26.04
git push origin v26.04
```

虽然你可以让 GitHub 在创建 release 时自动创建 tag，但不建议这样做。
GitHub 会创建*轻量级* tag，而我们希望使用兼容性更好的附注 tag（annotated tag）。

## 在 GitHub 上发布 release

- 可以将依赖库归档文件上传到带有发布说明的草稿 release，也可以将发布说明移至 GitHub 创建的 release 中（区别在于后者会被标记为 github-actions 所创建）。
- 将 tag 设置为 `v26.04`。
- 将 release 标题设置为 `v26.04`。
- 勾选"为此 release 创建讨论"。

## 发布 niri-ipc crate

```
cargo publish -p niri-ipc
```

## 启动 COPR 构建

通过网页上传，或者：

```
copr-cli build niri niri.spec
```

## 发布公告

在聊天室、社交媒体等平台发布公告。

## 更新 wayland.app 协议数据

- 安装 [wlprobe](https://github.com/PolyMeilex/wlprobe)。
- 克隆 https://github.com/vially/wayland-explorer。
- 生成数据：

    ```
    wlprobe > ./src/data/compositors/niri.json
    ```

- 手动添加 `"version": "26.04"`，然后清理不相关变更的差异，例如：
    - `wl_output` 的数量会根据连接了多少台显示器而变化。
    - `wp_drm_lease_device_v1` 的数量会根据 GPU 的数量而变化。
    - `org_kde_kwin_server_decoration_manager` 和 `zxdg_decoration_manager_v1` 仅在使用了 `prefer-no-csd` 时才会出现。
- 创建一个 Pull Request。
