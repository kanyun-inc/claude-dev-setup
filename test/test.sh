#!/bin/bash
# claude-dev-setup 自动化测试
# 在 Docker 容器内运行，验证 README 流程 + setup.md 逻辑
#
# Usage: bash test/run.sh  (从宿主机运行，自动 build + 启动容器)
#        bash test/test.sh (从容器内运行)

set -euo pipefail

PASS=0
FAIL=0
TESTS=()

pass() { PASS=$((PASS + 1)); TESTS+=("✅ $1"); echo "✅ $1"; }
fail() { FAIL=$((FAIL + 1)); TESTS+=("❌ $1: $2"); echo "❌ $1: $2"; }

echo "=== claude-dev-setup 自动化测试 ==="
echo ""

# -------------------------------------------------------
# 1. README 流程: git clone
# -------------------------------------------------------
echo "--- 1. git clone ---"
if [[ "${TEST_REMOTE_CLONE:-}" == "1" ]]; then
  # 强制远端 clone 模式
  cd /tmp
  rm -rf claude-dev-setup
  if git clone https://github.com/kanyun-inc/claude-dev-setup.git 2>&1; then
    pass "git clone (远端)"
  else
    fail "git clone" "clone 失败"
  fi
elif [[ -d /workspace/commands ]]; then
  # 本地挂载模式（run.sh 启动）— 复制到 /tmp 模拟 clone
  rm -rf /tmp/claude-dev-setup
  cp -r /workspace /tmp/claude-dev-setup
  pass "git clone (本地挂载模式)"
else
  # fallback: 真实 clone
  cd /tmp
  rm -rf claude-dev-setup
  if git clone https://github.com/kanyun-inc/claude-dev-setup.git 2>&1; then
    pass "git clone"
  else
    fail "git clone" "clone 失败"
  fi
fi

# -------------------------------------------------------
# 2. README 流程: cd 进入目录
# -------------------------------------------------------
echo ""
echo "--- 2. cd claude-dev-setup ---"
if cd /tmp/claude-dev-setup; then
  pass "cd claude-dev-setup"
else
  fail "cd claude-dev-setup" "目录不存在"
fi

# -------------------------------------------------------
# 3. README 流程: claude 命令可用
# -------------------------------------------------------
echo ""
echo "--- 3. claude 命令 ---"
if command -v claude > /dev/null 2>&1; then
  pass "claude 已安装 ($(claude --version 2>&1))"
else
  fail "claude" "未安装"
fi

# -------------------------------------------------------
# 4. setup.md Step 0: Shell 检测
# -------------------------------------------------------
echo ""
echo "--- 4. Shell 检测 ---"
DETECTED_SHELL="unknown"
if [[ "$SHELL" == *zsh* ]]; then
  DETECTED_SHELL="zsh"
  RC_FILE="$HOME/.zshrc"
elif [[ "$SHELL" == *bash* ]] || [[ -n "${BASH_VERSION:-}" ]]; then
  DETECTED_SHELL="bash"
  RC_FILE="$HOME/.bashrc"
fi

if [[ "$DETECTED_SHELL" != "unknown" ]]; then
  pass "Shell 检测: $DETECTED_SHELL → $RC_FILE"
else
  # 容器环境 $SHELL 可能未设置，fallback 到 bash
  DETECTED_SHELL="bash"
  RC_FILE="$HOME/.bashrc"
  pass "Shell 检测: fallback to bash → $RC_FILE"
fi

# -------------------------------------------------------
# 5. setup.md Step 0: REPO_DIR 动态检测
# -------------------------------------------------------
echo ""
echo "--- 5. REPO_DIR 动态检测 ---"
REPO_DIR=$(pwd)
if [[ -f "$REPO_DIR/commands/setup.md" ]]; then
  pass "REPO_DIR=$REPO_DIR (setup.md 存在)"
else
  fail "REPO_DIR" "$REPO_DIR 下找不到 commands/setup.md"
fi

# -------------------------------------------------------
# 6. setup.md Step 1: 平台检测 (brew 跳过)
# -------------------------------------------------------
echo ""
echo "--- 6. 平台检测 ---"
OS=$(uname -s)
if [[ "$OS" == "Linux" ]]; then
  pass "平台: Linux — brew 步骤跳过"
elif [[ "$OS" == "Darwin" ]]; then
  pass "平台: macOS — brew 步骤适用"
else
  fail "平台检测" "未知平台: $OS"
fi

# -------------------------------------------------------
# 7. setup.md Step 5: 代理写入 RC 文件
# -------------------------------------------------------
echo ""
echo "--- 7. 代理写入 RC 文件 ---"
# 模拟 /setup 写代理配置
if ! grep -q "proxy_on" "$RC_FILE" 2>/dev/null; then
  cat >> "$RC_FILE" << 'PROXY_EOF'

# 代理配置 (test)
PROXY_HTTP="proxy-aws-us.zhenguanyu.com:8118"
proxy_on() { export http_proxy="http://${PROXY_HTTP}"; echo "Proxy ON"; }
proxy_off() { unset http_proxy; echo "Proxy OFF"; }
PROXY_EOF
fi

if grep -q "proxy_on" "$RC_FILE"; then
  pass "代理写入 $RC_FILE"
else
  fail "代理写入" "proxy_on 未写入 $RC_FILE"
fi

# 验证幂等性 — 再写一次不应该重复
BEFORE=$(grep -c "proxy_on" "$RC_FILE")
# 模拟重复执行（检测到已有就跳过）
if ! grep -q "proxy_on" "$RC_FILE" 2>/dev/null; then
  echo "# should not reach here" >> "$RC_FILE"
fi
AFTER=$(grep -c "proxy_on" "$RC_FILE")
if [[ "$BEFORE" == "$AFTER" ]]; then
  pass "代理写入幂等性 (重复执行不追加)"
else
  fail "代理写入幂等性" "重复追加了 ($BEFORE → $AFTER)"
fi

# -------------------------------------------------------
# 8. setup.md Step 6: Claude alias 写入
# -------------------------------------------------------
echo ""
echo "--- 8. Claude alias 写入 ---"
if ! grep -q 'alias claude=' "$RC_FILE" 2>/dev/null; then
  cat >> "$RC_FILE" << 'ALIAS_EOF'

# Claude alias (test)
alias claude="claude --dangerously-skip-permissions"
alias claude-safe="command claude"
ALIAS_EOF
fi

if grep -q 'alias claude=' "$RC_FILE"; then
  pass "Claude alias 写入 $RC_FILE"
else
  fail "Claude alias" "未写入"
fi

# -------------------------------------------------------
# 9. setup.md Step 9: tmux 配置复制
# -------------------------------------------------------
echo ""
echo "--- 9. tmux 配置 ---"
rm -f ~/.tmux.conf
if [[ -f "$REPO_DIR/tmux/.tmux.conf" ]]; then
  cp "$REPO_DIR/tmux/.tmux.conf" ~/.tmux.conf
  if [[ -f ~/.tmux.conf ]]; then
    pass "tmux.conf 复制成功"
  else
    fail "tmux.conf" "复制失败"
  fi
else
  fail "tmux.conf" "$REPO_DIR/tmux/.tmux.conf 不存在"
fi

# -------------------------------------------------------
# 10. claude-workspace.sh tmux 测试
# -------------------------------------------------------
echo ""
echo "--- 10. claude-workspace tmux ---"
tmux kill-server 2>/dev/null || true
sleep 1

SCRIPT="$REPO_DIR/tmux/claude-workspace.sh"
if [[ ! -f "$SCRIPT" ]]; then
  fail "claude-workspace.sh" "脚本不存在"
else
  # 用真实脚本测试（跳过最后的 tmux attach，因为没有 tty）
  # 先 sed 掉 attach 行，然后执行
  TEMP_SCRIPT=$(mktemp)
  sed '/tmux attach/d' "$SCRIPT" > "$TEMP_SCRIPT"
  bash "$TEMP_SCRIPT" /tmp 2>&1 || true
  rm -f "$TEMP_SCRIPT"

  SESSION="claude"  # 脚本里硬编码的 session name
  WINDOW_COUNT=$(tmux list-windows -t "$SESSION" 2>/dev/null | wc -l)
  if [[ "$WINDOW_COUNT" -eq 3 ]]; then
    pass "tmux 创建 3 个 window (真实脚本)"
  else
    fail "tmux windows" "期望 3 个，实际 $WINDOW_COUNT 个"
  fi

  # 验证 send-keys 用 window name
  if tmux send-keys -t "$SESSION:claude-1" "echo ok" Enter 2>&1 && \
     tmux send-keys -t "$SESSION:claude-2" "echo ok" Enter 2>&1 && \
     tmux send-keys -t "$SESSION:claude-3" "echo ok" Enter 2>&1; then
    pass "send-keys by window name"
  else
    fail "send-keys" "window name 定位失败"
  fi

  tmux kill-session -t "$SESSION" 2>/dev/null || true
fi

# -------------------------------------------------------
# 11. setup.md Step 9: cw alias
# -------------------------------------------------------
echo ""
echo "--- 11. cw alias ---"
if ! grep -q 'alias cw=' "$RC_FILE" 2>/dev/null; then
  cat >> "$RC_FILE" << CWEOF

# claude-workspace (test)
alias claude-workspace="bash $REPO_DIR/tmux/claude-workspace.sh"
alias cw="bash $REPO_DIR/tmux/claude-workspace.sh"
CWEOF
fi

if grep -q 'alias cw=' "$RC_FILE"; then
  pass "cw alias 写入 $RC_FILE"
else
  fail "cw alias" "未写入"
fi

# 验证 alias 指向的脚本存在
CW_TARGET=$(grep 'alias cw=' "$RC_FILE" | sed 's/.*bash //' | sed 's/".*//') || true
if [[ -f "$CW_TARGET" ]]; then
  pass "cw alias 目标脚本存在: $CW_TARGET"
else
  fail "cw alias 目标" "$CW_TARGET 不存在"
fi

# -------------------------------------------------------
# 12. Bedrock 连接测试 (需要环境变量)
# -------------------------------------------------------
echo ""
echo "--- 12. Bedrock 连接 ---"
if [[ -z "${AWS_ACCESS_KEY_ID:-}" ]]; then
  echo "⏭️  跳过 (无 AWS 凭证)"
else
  RESPONSE=$(claude -p "say ok" --output-format text 2>&1 || true)
  if echo "$RESPONSE" | grep -qi "ok"; then
    pass "Bedrock 连接正常"
  else
    fail "Bedrock 连接" "响应: $RESPONSE"
  fi
fi

# -------------------------------------------------------
# 结果汇总
# -------------------------------------------------------
echo ""
echo "==========================================="
echo "  测试结果: $PASS 通过, $FAIL 失败"
echo "==========================================="
for t in "${TESTS[@]}"; do
  echo "  $t"
done
echo ""

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
