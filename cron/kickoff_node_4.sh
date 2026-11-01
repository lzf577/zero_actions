#!/bin/sh

# 一键启动第四版 (网段 10.3.4.0 / 自循环链式接力)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
[ -f "$SCRIPT_DIR/token.env" ] && . "$SCRIPT_DIR/token.env"

TOKEN="${TOKEN:-$GH_PAT}"
OWNER="lzf577"
REPO="zero_actions"
WORKFLOW="zero_acritons_4.yml"
BRANCH="main"

if [ -z "$TOKEN" ]; then
  echo "❌ 错误: 未检测到 GitHub Token，请在 $SCRIPT_DIR/token.env 中配置 TOKEN！"
  exit 1
fi

echo "🚀 准备启动 $WORKFLOW 并开启自循环接力链条..."

response=$(curl -k -s -o /tmp/resp.txt -w "%{http_code}" -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/workflows/$WORKFLOW/dispatches" \
  -d "{\"ref\":\"$BRANCH\",\"inputs\":{\"PAT_TOKEN\":\"$TOKEN\"}}")

if [ "$response" -eq 204 ]; then
  echo "✅ 成功触发 $WORKFLOW！工作流已开始执行自循环接力。"
else
  echo "❌ 触发失败，HTTP 状态码: $response"
  [ -f /tmp/resp.txt ] && cat /tmp/resp.txt && echo ""
fi
