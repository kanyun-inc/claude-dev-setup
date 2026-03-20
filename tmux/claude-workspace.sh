#!/bin/bash
# 启动 tmux session，开 3 个 window 各跑 claude
# Usage: bash claude-workspace.sh [project-dir]
#
# 建议加 alias 到 ~/.zshrc:
#   alias claude-workspace="bash ~/develop/claude-dev-setup/tmux/claude-workspace.sh"

SESSION="claude"
DIR="${1:-$(pwd)}"

# 如果 session 已存在，直接 attach
if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
  exit 0
fi

# 创建 session，第一个 window 跑 claude
tmux new-session -d -s "$SESSION" -c "$DIR" -n "claude-1"
tmux send-keys -t "$SESSION:claude-1" "claude" Enter

# 第二个 window（不带 -t，自动在当前 session 创建）
tmux new-window -c "$DIR" -n "claude-2"
tmux send-keys -t "$SESSION:claude-2" "claude" Enter

# 第三个 window
tmux new-window -c "$DIR" -n "claude-3"
tmux send-keys -t "$SESSION:claude-3" "claude" Enter

# 回到第一个 window，attach
tmux select-window -t "$SESSION:claude-1"
tmux attach -t "$SESSION"
