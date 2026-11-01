#!/bin/bash
# zero_actions 链式接力守护犬 (Watchdog)
# 用于检查 NO4 和 NO5 是否处于运行中，若双双掉线则自动重新激活接力

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
[ -f "$SCRIPT_DIR/token.env" ] && . "$SCRIPT_DIR/token.env"

TOKEN="${TOKEN:-$GH_PAT}"
OWNER="lzf577"
REPO="zero_actions"

if [ -z "$TOKEN" ]; then
  echo "❌ 未检测到 GitHub Token"
  exit 1
fi

# 查询是否有 in_progress 或 queued 的 NO4 / NO5
STATUS=$(python3 -c "
import urllib.request, json
token = '$TOKEN'
try:
    req = urllib.request.Request('https://api.github.com/repos/$OWNER/$REPO/actions/runs?status=in_progress', headers={
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json'
    })
    with urllib.request.urlopen(req, timeout=10) as resp:
        runs = json.loads(resp.read().decode()).get('workflow_runs', [])
        active = [r['name'] for r in runs if 'NO4' in r['name'] or 'NO5' in r['name']]
        if active:
            print('ACTIVE:' + ','.join(active))
        else:
            print('IDLE')
except Exception as e:
    print('ERROR:' + str(e))
")

if [[ "$STATUS" == ACTIVE* ]]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 链式接力正常运转中: $STATUS"
elif [[ "$STATUS" == "IDLE" ]]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ 检测到 NO4 与 NO5 均未运行（循环已中断），正在自动重新启动接力..."
  bash "$SCRIPT_DIR/kickoff_node_4.sh"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 检查异常: $STATUS"
fi
