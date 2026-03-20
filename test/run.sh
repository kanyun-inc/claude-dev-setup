#!/bin/bash
# 一键运行 claude-dev-setup 测试
# Usage: bash test/run.sh
#
# 需要以下环境变量（Bedrock 连接测试用，可选）:
#   AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, ANTHROPIC_MODEL
#   HTTP_PROXY, HTTPS_PROXY

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGE_NAME="claude-dev-setup-test"

echo "=== 构建测试镜像 ==="
docker build -t "$IMAGE_NAME" -f "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR" 2>&1

echo ""
echo "=== 运行测试 ==="
# 挂载本地 repo 到 /workspace，测试本地最新代码
docker run --rm \
  -v "$REPO_DIR:/workspace:ro" \
  -e CLAUDE_CODE_USE_BEDROCK="${CLAUDE_CODE_USE_BEDROCK:-}" \
  -e AWS_REGION="${AWS_REGION:-}" \
  -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}" \
  -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}" \
  -e ANTHROPIC_MODEL="${ANTHROPIC_MODEL:-}" \
  -e ANTHROPIC_DEFAULT_HAIKU_MODEL="${ANTHROPIC_DEFAULT_HAIKU_MODEL:-}" \
  -e HTTP_PROXY="${HTTP_PROXY:-}" \
  -e HTTPS_PROXY="${HTTPS_PROXY:-}" \
  -e http_proxy="${http_proxy:-}" \
  -e https_proxy="${https_proxy:-}" \
  -e no_proxy="${no_proxy:-}" \
  "$IMAGE_NAME" \
  bash /workspace/test/test.sh
