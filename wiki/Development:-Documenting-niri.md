niri 的文档文件位于 `docs/wiki/` 目录下，并且至少可以在三个系统中查看和浏览：

- GitHub 仓库的 Markdown 文件预览
- [GitHub 仓库的 wiki](https://github.com/YaLTeR/niri/wiki)
- [文档网站](https://yalter.github.io/niri/)

## GitHub 仓库的 wiki

这是通过 `.github/workflows/ci.yml` 中的 `publish-wiki` 作业生成的。为了使此作业在您的 fork 中按预期运行，您需要在 GitHub 仓库的设置中启用 wiki 功能。作为贡献者，这有助于验证 wiki 是否按预期生成。

## 文档网站

文档网站由 [mkdocs](https://www.mkdocs.org/) 生成。配置文件位于 `docs/` 目录下。

要在本地设置和运行文档站点，建议使用 [uv](https://docs.astral.sh/uv/)。

### 使用 uv 为本地站点提供服务

在 `docs/` 子目录中：

- `uv sync`
- `uv run mkdocs serve`

文档网站现在应该可以通过 http://127.0.0.1:8000/niri/ 访问。

在开发服务器运行期间对文档进行更改会导致浏览器自动刷新页面。

> [!TIP]
> 图片可能无法显示，因为它们存储在 Git LFS 上。
> 如果是这种情况，请运行`git lfs pull`。

## 元素

在 GitHub、GitHub 仓库的 wiki 和文档站点中，markdown 文件预览中的链接、警告、图像和代码片段等元素应该能够按预期工作。

### 链接

除非是外部链接，否则链接在任何情况下都应该是相对路径（例如 `./FAQ.md`）。如果链接旨在引导用户访问页面上的特定部分，则应使用锚点（例如 `./Getting-Started.md#nvidia`）。

> [!TIP]
> 如果相对链接指向不存在的文档或不存在的锚点，mkdocs 将终止。
> 这意味着 CI 流水线在构建文档时会失败，本地执行 `mkdocs serve` 也会失败。

### 警告

> [!IMPORTANT]
> 这与您可能遇到的其他基于 `mkdocs` 的文档有重要的区别。

警告或提示信息应该按照 GitHub 的定义编写（https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts）。

上面的警告信息是这样写的：

```
> [!IMPORTANT]
> 这与您可能遇到的其他基于 `mkdocs` 的文档有重要的区别。
```

### 图片

图片应有指向 `docs/wiki/img/` 中资源的相对链接，并应包含合理的替代文本（alt-text）。

### 视频

为了与 mkdocs 和 GitHub Wiki 兼容，视频需要用 `<video>` 标签包裹（由 mkdocs 显示），并且需要再次提供视频链接作为回退文本（由 GitHub Wiki 显示），并用空行填充。

```html
<video controls src="https://github.com/user-attachments/assets/379a5d1f-acdb-4c11-b36c-e85fd91f0995">

https://github.com/user-attachments/assets/379a5d1f-acdb-4c11-b36c-e85fd91f0995

</video>
```

### 片段

通常情况下，配置和代码片段都应该使用某种语言进行注释。

如果代码片段中使用的语言是 KDL，请按如下方式打开代码块：

```md
```kdl
```
