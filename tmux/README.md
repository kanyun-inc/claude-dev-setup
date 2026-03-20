# tmux 配置

适合日常开发的 tmux 配置，开箱即用。

## 安装

```bash
# 安装 tmux
brew install tmux

# 复制配置
cp .tmux.conf ~/.tmux.conf

# 重载（如果 tmux 已在运行）
tmux source-file ~/.tmux.conf
```

## 主要改动

| 功能 | 默认值 | 本配置 |
|------|--------|--------|
| 前缀键 | `Ctrl+b` | `Ctrl+a`（更顺手） |
| 鼠标 | 关闭 | 开启（点击/拖拽/滚轮） |
| 分屏 | `"` / `%` | `\|`（水平）/ `-`（垂直） |
| 窗口编号 | 从 0 开始 | 从 1 开始 |
| 新窗口路径 | 默认目录 | 保持当前路径 |
| 历史行数 | 2000 | 50000 |
| True color | 关闭 | 开启 |

## Claude 工作区

一键开 3 个 tmux window，每个跑一个 claude（前提：已配好 claude alias）：

```bash
# 加 alias 到 ~/.zshrc（/setup 会自动配）
alias cw="bash ~/develop/dev-setup/tmux/claude-workspace.sh"

# 使用
cw                    # 当前目录，3 个 claude
cw ~/develop/rush     # 指定项目目录
```

`Ctrl+a 1/2/3` 切换窗口。重复执行 `cw` 会 attach 已有 session。

## 常用快捷键

```
Ctrl+a |    水平分屏
Ctrl+a -    垂直分屏
Ctrl+a c    新窗口
Ctrl+a 1-9  切换窗口
鼠标点击     切换 pane
鼠标拖拽     调整 pane 大小
```
