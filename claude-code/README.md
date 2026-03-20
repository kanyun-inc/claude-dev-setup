# Claude Code 配置参考

> Claude Code 安装和 Bedrock 接入请按公司接入手册操作：https://confluence.zhenguanyu.com/pages/viewpage.action?pageId=913905429

## alias 配置

`/setup` 会自动配置以下 alias：

```bash
# 默认跳过权限确认（提高效率），claude-safe 恢复确认模式
alias claude="claude --dangerously-skip-permissions"
alias claude-safe="command claude"
```

## 代理配置

Bedrock API 请求需要走代理，`/setup` 会自动配置 `proxy_on` / `proxy_off` 函数。

手动配置见 [zshrc-claude.sh](zshrc-claude.sh)。
