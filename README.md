# TXHBalance Civilization VI 模组

运行模组在 `mod/TXHBalance/`。玩法、平衡调整及安装说明见 [模组说明](mod/TXHBalance/README.md)。

## 目录约定

```text
mod/TXHBalance/     游戏运行文件，可整体复制到 Mods
dev/tools/          本地开发、打包和验证工具
dev/tests/          本地自动回归测试
dev/assets/         本地源素材
dev/reproductions/  历史问题复现及原始源码快照
review/             审核报告、验证证据和历史备份
dist/               仅包含运行文件的安装包
```

Git只跟踪 `mod/`、本说明、`.gitignore` 及 `.gitattributes`。`dev/`、`review/`、`dist/` 均为本地资料，由 `.gitignore` 排除；已有开发工具和测试文件已从当前分支跟踪清单移出。新克隆的仓库不会包含本机工具或审核资料。

## 安装与开发

将 `mod/TXHBalance/` 整体放入 Civilization VI 的 `Mods` 目录，或使用 `dist/` 中的安装包。运行文件夹包含 manifest、运行资源和安装说明，不包含Git、测试或开发工具。

本机保留的验证入口：`powershell -NoProfile -ExecutionPolicy Bypass -File dev/tools/check.ps1`。
本机打包入口：`python -B dev/tools/package_mod.py`。

修复和目录整理保存在 `fix/civ6-review-2026-10-05` 分支，等待实机测试确认后合并。
