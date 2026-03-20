# Homebrew 配置

## 安装 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 配置清华镜像源

brew 默认从 GitHub 拉取，国内很慢。配置清华镜像源后速度快很多。

在 `~/.zshrc` 中加：

```bash
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
```

生效：`source ~/.zshrc`

## 安装团队依赖

```bash
brew bundle --file=Brewfile
```

或者手动安装核心工具：

```bash
brew install git gh jq tmux nvm pnpm ripgrep fd bat fzf awscli
brew install --cask docker
```

## gh 登录

```bash
gh auth login
# 选 GitHub.com → HTTPS → Login with a web browser
```
