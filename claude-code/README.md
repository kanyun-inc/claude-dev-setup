# Claude Code + Bedrock 配置

## 安装 Claude Code

```bash
# macOS / Linux
npm install -g @anthropic-ai/claude-code
```

## Bedrock 接入

Claude Code 通过 AWS Bedrock 调用模型，不直接调 Anthropic API。

### 1. AWS 凭证

找管理员获取 IAM 用户的 Access Key，然后配置：

```bash
# 方法 1: 环境变量（推荐，写到 .zshrc）
export AWS_ACCESS_KEY_ID="你的AK"
export AWS_SECRET_ACCESS_KEY="你的SK"
export AWS_REGION="us-west-2"

# 方法 2: AWS CLI profile
aws configure --profile claude-profile
```

### 2. 启用 Bedrock 模式

在 `.zshrc` 中加：

```bash
# Claude Code Bedrock 模式
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-west-2

# 模型配置（使用公司的 Application Inference Profile）
export ANTHROPIC_MODEL="arn:aws:bedrock:us-west-2:<ACCOUNT_ID>:application-inference-profile/<PROFILE_ID>[1m]"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="arn:aws:bedrock:us-west-2:<ACCOUNT_ID>:application-inference-profile/<HAIKU_PROFILE_ID>"
```

### 3. 代理配置

Bedrock API 请求需要走代理：

```bash
# 代理配置（写到 .zshrc）
PROXY_HTTP="proxy-aws-us.zhenguanyu.com:8118"

export http_proxy="http://${PROXY_HTTP}"
export https_proxy="http://${PROXY_HTTP}"
export HTTP_PROXY="http://${PROXY_HTTP}"
export HTTPS_PROXY="http://${PROXY_HTTP}"
export no_proxy="localhost,127.0.0.1,*.local,10.*,192.168.*"
export NO_PROXY="localhost,127.0.0.1,*.local,10.*,192.168.*"
```

### 4. 验证

```bash
# 启动 Claude Code
claude

# 或直接测试
claude -p "say hello"
```

### 5. 实用配置

```bash
# 启用 Agent Teams（子 agent 编排）
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

## 常见问题

#### Q: 报 "Access to Anthropic models is not allowed from unsupported countries"

代理没配或没生效。确认 `echo $HTTP_PROXY` 有值，且 `curl -x $HTTP_PROXY https://bedrock-runtime.us-west-2.amazonaws.com` 能通。

#### Q: 报 "Could not resolve credentials"

AWS 凭证没配。检查 `echo $AWS_ACCESS_KEY_ID` 是否有值。

#### Q: 想用 1M 上下文窗口

在模型 ARN 后面加 `[1m]` 后缀：

```bash
export ANTHROPIC_MODEL="arn:aws:bedrock:us-west-2:<ACCOUNT_ID>:application-inference-profile/<PROFILE_ID>[1m]"
```

## 参考配置

完整的 `.zshrc` 片段见 [zshrc-claude.sh](zshrc-claude.sh)。
