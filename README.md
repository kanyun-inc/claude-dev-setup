<h1 align="center">claude-dev-setup</h1>

<p align="center">
  <strong>一条命令搞定 Claude Code 开发环境</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS-blue?style=flat-square&logo=apple" alt="macOS">
  <img src="https://img.shields.io/badge/Shell-zsh-green?style=flat-square" alt="zsh">
  <img src="https://img.shields.io/badge/AI-Claude_Code-purple?style=flat-square" alt="Claude Code">
</p>

---

## 为什么做这个

配环境总要踩坑：brew 装不上（镜像源没配）、docker pull 超时（docker.io 被墙）、tmux 快捷键不顺手...

**claude-dev-setup 把这些坑填好了。** 在 Claude Code 里执行 `/setup`，Claude 会交互式地帮你检查、安装、配置，遇到问题自己判断修复。

## 执行后你会得到

```
✅ brew          — Homebrew + 清华镜像源（告别龟速下载）
✅ gh            — GitHub CLI（已登录）
✅ jq            — JSON 处理
✅ tmux          — 终端复用（Ctrl+a 前缀、鼠标支持）
✅ nvm + node    — Node.js 版本管理
✅ claude alias  — claude 命令默认跳过权限确认（提效）
✅ 代理          — proxy_on / proxy_off 一键切换
✅ Docker        — Registry 登录 + 代理配置指引
✅ claude-workspace — tmux 一键开 3 个 claude 窗口并行开发
```

## 前提

先按公司接入手册配好 Claude Code：https://confluence.zhenguanyu.com/pages/viewpage.action?pageId=913905429

确认 `claude` 命令能正常启动后再继续。

## 使用

```bash
# 1. Clone
git clone git@github.com:kanyun-inc/claude-dev-setup.git ~/develop/claude-dev-setup

# 2. 启动 Claude Code
cd ~/develop/claude-dev-setup && claude

# 3. 一键配置
/setup
```

Claude 会逐步引导你完成所有配置。已有的工具会自动跳过，缺什么补什么。

> Docker Desktop 的代理需要在 GUI 里配，Claude 会告诉你怎么操作。

## 配好后的日常

```bash
# 开 3 个 claude 窗口并行开发
claude-workspace ~/develop/my-project

# 短别名也可以
cw ~/develop/my-project

# tmux 窗口切换
Ctrl+a 1    # 第一个 claude
Ctrl+a 2    # 第二个 claude
Ctrl+a 3    # 第三个 claude

# 代理开关
proxy_on    # 开代理（默认开）
proxy_off   # 关代理

# Claude Code
claude      # 默认跳过权限确认
claude-safe # 带权限确认
```

## 进阶：双 AI 互搏 + 多 Agent 并行

基础环境配好后，可以试试 [Sparring](https://github.com/krislavten/dual-ai-workflow) — Claude Code 执行 + Cursor Agent 审查的双 AI 协作工作流。还可以搭配 ClawTeam 实现多 Agent 并行编排。

安装：Setup 完成后 Claude 会提示是否安装。

## 目录说明

| 目录 | 内容 |
|------|------|
| [commands/setup.md](commands/setup.md) | `/setup` 命令 — Claude Code 交互式配置 |
| [docker/](docker/README.md) | Docker Registry 登录（阿里云）+ 代理配置 |
| [claude-code/](claude-code/README.md) | Claude Code alias、代理配置参考 |
| [tmux/](tmux/README.md) | tmux 配置 + claude-workspace 脚本 |
| [brew/](brew/README.md) | Homebrew 镜像源 + Brewfile |
