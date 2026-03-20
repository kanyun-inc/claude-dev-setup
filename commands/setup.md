---
description: 一键配置开发环境 — brew、代理、Docker、tmux、claude alias
argument-hint: (no arguments needed)
---

# Dev Setup

你正在帮用户配置开发环境。这是一个交互式的 setup，逐步检查和安装，遇到问题自己判断并修复。

**用中文和用户交流。**

## Step 0: 检测 Shell 和 RC 文件

先确定用户的 shell 和对应的 rc 文件：

```bash
echo "SHELL=$SHELL"
```

- 如果 `$SHELL` 包含 `zsh`，RC 文件是 `~/.zshrc`
- 如果 `$SHELL` 包含 `bash`，RC 文件是 `~/.bashrc`
- 其他情况问用户用什么 shell

**后续所有"追加到 RC 文件"的操作，都写入这个文件。** 在后续步骤中用 `$RC_FILE` 指代。

同时确认当前 repo 路径（后续步骤会用到）：

```bash
pwd
```

记住这个路径为 `$REPO_DIR`。

## Step 1: Homebrew（仅 macOS）

```bash
uname -s
```

如果是 Linux，跳过 Step 1-3 中 brew 相关的部分，改用 `apt-get` 或对应包管理器。

如果是 macOS：

```bash
command -v brew
```

如果没有：
```bash
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

安装完后检查是否在 PATH 中（Apple Silicon 的 brew 在 `/opt/homebrew/bin`）。如果不在，追加到 RC 文件：
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## Step 2: Brew 清华镜像源（仅 macOS）

检查 RC 文件是否已有 `HOMEBREW_BOTTLE_DOMAIN`。

如果没有，追加到 RC 文件：
```
# Homebrew 清华镜像源
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
```

写完后在当前 session 直接 `export` 这些变量让其立即生效。

## Step 3: 安装依赖

逐个用 `command -v` 检查，**只装缺的**，已有的跳过。

macOS 用 brew：
- `gh` — GitHub CLI
- `jq` — JSON 处理
- `tmux` — 终端复用
- `nvm` — Node 版本管理
- Docker Desktop — `command -v docker`，如果没有用 `brew install --cask docker`

Linux 用 apt-get 或对应包管理器：
- `gh` — `apt-get install gh` 或参考 https://github.com/cli/cli/blob/trunk/docs/install_linux.md
- `jq` — `apt-get install jq`
- `tmux` — `apt-get install tmux`
- `nvm` — `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash`
- Docker — 跳过（Linux 上 Docker 通常单独安装）

## Step 4: Node.js

```bash
command -v node && node --version
```

如果没有，用 nvm 安装：
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
# macOS 上 brew 安装的 nvm 路径不同
[ -s "$(brew --prefix nvm 2>/dev/null)/nvm.sh" ] && source "$(brew --prefix nvm)/nvm.sh"
nvm install 22
```

如果 RC 文件里没有 nvm 初始化代码，追加：
```
# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

macOS 上如果 nvm 是 brew 装的，改用：
```
# nvm (brew)
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
```

## Step 5: 代理

检查 RC 文件是否已有 `proxy_on`。

如果没有，追加到 RC 文件：
```
# 代理配置
PROXY_HTTP="proxy-aws-us.zhenguanyu.com:8118"
PROXY_SOCKS5="proxy-jp.zhenguanyu.com:8388"

proxy_on() {
    export http_proxy="http://${PROXY_HTTP}"
    export https_proxy="http://${PROXY_HTTP}"
    export HTTP_PROXY="http://${PROXY_HTTP}"
    export HTTPS_PROXY="http://${PROXY_HTTP}"
    export all_proxy="socks5://${PROXY_SOCKS5}"
    export ALL_PROXY="socks5://${PROXY_SOCKS5}"
    export no_proxy="localhost,127.0.0.1,*.local,10.*,192.168.*"
    export NO_PROXY="localhost,127.0.0.1,*.local,10.*,192.168.*"
    echo "Proxy ON: ${PROXY_HTTP}"
}

proxy_off() {
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
    unset all_proxy ALL_PROXY no_proxy NO_PROXY
    echo "Proxy OFF"
}

# 默认开启代理（Bedrock API 需要）
proxy_on
```

写完后在当前 session 也执行一下 proxy_on 的内容，确保后续步骤能访问外网。

## Step 6: Claude Code alias

检查 RC 文件是否已有 `alias claude=`。如果没有，追加到 RC 文件：
```
# Claude Code — 默认跳过权限确认（提高效率）
# 使用 claude-safe 恢复确认模式
alias claude="claude --dangerously-skip-permissions"
alias claude-safe="command claude"
```

## Step 7: Cursor Agent CLI

```bash
command -v agent
```

如果没有：
```bash
curl https://cursor.com/install -fsS | bash
```

如果 curl 失败，告诉用户手动安装：https://cursor.com/install

## Step 8: GitHub CLI 登录

```bash
gh auth status
```

如果没登录，问用户："gh 需要登录 GitHub，现在登录吗？"

如果是，执行 `gh auth login`（这个是交互式的，让用户自己操作）。

## Step 9: tmux 配置

检查 `~/.tmux.conf` 是否存在。

如果不存在，用 Step 0 记住的 `$REPO_DIR` 复制：
```bash
cp "$REPO_DIR/tmux/.tmux.conf" ~/.tmux.conf
```

如果已存在，跳过，告诉用户可以手动对比更新。

### claude-workspace 快捷命令

问用户："要配置 claude-workspace 吗？一键开 tmux + 3 个 claude 窗口，适合并行开发。"

如果用户同意，检查 RC 文件是否已有 `alias claude-workspace=`。如果没有，追加到 RC 文件（用 `$REPO_DIR` 拼路径）：
```
# tmux + claude 工作区（3 个 window 各跑一个 claude）
alias claude-workspace="bash $REPO_DIR/tmux/claude-workspace.sh"
alias cw="claude-workspace"
```

告诉用户：
```
用法: claude-workspace [项目目录]
  claude-workspace              — 在当前目录开 3 个 claude
  claude-workspace ~/develop/rush  — 在指定项目目录开 3 个 claude

tmux 切换窗口: Ctrl+a 1/2/3
```

## Step 10: Docker 配置提醒

Docker Desktop 的代理需要在 GUI 里配，脚本搞不定。告诉用户：

```
Docker 需要手动配置两件事：

1. Registry 登录：
   - 用 LDAP 登录阿里云: https://signin.aliyun.com/yfd.onaliyun.com/login.htm
   - 设置 Docker 固定密码: https://cr.console.aliyun.com/cn-beijing/instance/cri-szw6f6bhrky0c8jk/credentials
   - 登录: docker login --username=<LDAP>@yfd docker-registry.zhenguanyu.com

2. 代理（拉 docker.io 镜像）：
   - Docker Desktop → Settings → Resources → Proxies
   - HTTP/HTTPS: http://proxy.zhenguanyu.com:8118
   - Bypass: localhost,127.0.0.1,*.zhenguanyu.com,docker-registry.zhenguanyu.com,*.cn-beijing.aliyuncs.com

详见: https://github.com/kanyun-inc/claude-dev-setup/blob/main/docker/README.md
```

## Step 11: 验证

最后跑一轮验证：
```bash
echo "=== 验证 ==="
command -v brew && echo "✅ brew" || echo "⚠️  brew (仅 macOS 需要)"
command -v git && echo "✅ git" || echo "❌ git"
command -v gh && echo "✅ gh" || echo "❌ gh"
command -v node && echo "✅ node $(node --version)" || echo "❌ node"
command -v jq && echo "✅ jq" || echo "❌ jq"
command -v tmux && echo "✅ tmux" || echo "❌ tmux"
command -v claude && echo "✅ claude" || echo "❌ claude"
command -v agent && echo "✅ cursor agent" || echo "⚠️  cursor agent (可选)"
gh auth status 2>&1 | grep -q "Logged in" && echo "✅ gh 已登录" || echo "⚠️  gh 未登录"
[ -f ~/.tmux.conf ] && echo "✅ tmux 配置" || echo "⚠️  tmux 未配置"
echo "$http_proxy" | grep -q proxy && echo "✅ 代理已开启" || echo "⚠️  代理未开启"
```

告诉用户结果，以及任何还需要手动处理的事项。

## Step 12: Sparring（可选）

告诉用户：

```
想试试双 AI 互搏吗？Sparring 让 Claude Code 写代码、Cursor Agent 审查，互相 review 提升质量。
还可以搭配 ClawTeam 实现多 Agent 并行编排。

详情: https://github.com/krislavten/dual-ai-workflow
```

问用户："要安装 Sparring 吗？"

如果用户同意，告诉用户退出当前 Claude Code session 后执行：
```
/plugin marketplace add krislavten/dual-ai-workflow
/plugin install sparring@sparring
```

ClawTeam（多 Agent 并行编排）需要额外安装：
```bash
pipx install clawteam
```

告诉用户安装完重启 Claude Code session 后就能使用 `/sparring:*` 命令。

## 完成

告诉用户（用 Step 0 检测到的 RC 文件名）：

```
Setup 完成！

生效配置: source <RC_FILE>

常用命令:
  claude              — Claude Code（默认跳过权限确认）
  claude-safe         — Claude Code（带权限确认）
  proxy_on / proxy_off — 开关代理
  tmux                — 终端复用（Ctrl+a 前缀）
```
