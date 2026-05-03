# niri-wiki-chinese

这是 [niri 窗口管理器](https://github.com/niri-wm/niri) wiki 的非官方中文翻译仓库。


译者水平一般，且本文为仓促完成，若您有更好的翻译，欢迎提出。

## 在线阅读

https://docs.akass.cn/niri/

网站为了试图获取良好的访问速度，使用了 CDN，故可能文章受缓存影响并不是最新，请以仓库文件内容为准。

## 用法

推荐使用 uv。

```
uv sync
uv run mkdocs serve
```

构建：

```
uv run mkdocs build
```

## 同步上游

niri 的 docs 目录有更新时，跑一下这个脚本：

```
./sync-upstream.sh
```

它会自动从上游拉文档，把新增/修改的 wiki 页面移动到 `wiki/en/` 下面。之后你需要手动翻译到 `wiki/zh/`。

如果还没配过 upstream remote，脚本会自动帮你加上。mkdocs.yaml 冲突也会自动处理，保留本地的 zh/en 导航结构。
不过处理的结果如何，最好还是再看一眼。

## 注意事项

翻译的时候注意让 zh 文件的行数和 en 保持一致，英文哪里换行中文就哪里换行，这样diff看起来方便一点。

## 许可证

本项目基于原项目的许可证 GPLv3 进行翻译和分发。详情请查看 [LICENSE](LICENSE) 文件。

## 相关链接

- [niri 官方仓库](https://github.com/niri-wm/niri)
- [niri 官方文档](https://github.com/niri-wm/niri/wiki)
- [niri 新版文档](https://niri-wm.github.io/niri/)
- [向 niri 报告问题](https://github.com/niri-wm/niri/issues)

---

> [!WARNING]
> 注意：这是非官方翻译，如有疑问请以官方英文文档为准。
>
> 本翻译基于 Commit [5f6f131](https://github.com/niri-wm/niri/commit/5f6f131b24826a01374d5cd87b281bd7ea181537)