FROM node:22-slim

RUN apt-get update -qq && \
    apt-get install -y -qq git tmux curl jq > /dev/null 2>&1 && \
    rm -rf /var/lib/apt/lists/*

# 安装 Claude Code
RUN npm install -g @anthropic-ai/claude-code > /dev/null 2>&1

WORKDIR /workspace
