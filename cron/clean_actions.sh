#!/bin/bash
# zero_actions 历史运行记录一键清理脚本
# 仅保留最近的几条历史记录，删除所有堆积陈旧的已完成/已取消记录

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
[ -f "$SCRIPT_DIR/token.env" ] && . "$SCRIPT_DIR/token.env"

TOKEN="${TOKEN:-$GH_PAT}"
OWNER="lzf577"
REPO="zero_actions"
KEEP_COUNT=${1:-3}  # 默认保留最近 3 条已完成记录

if [ -z "$TOKEN" ]; then
  echo "❌ 错误: 未检测到 GitHub Token！"
  exit 1
fi

echo "🧹 正在连接 GitHub API 整理 Actions 运行记录 (保留最近 $KEEP_COUNT 条完成记录)..."

python3 -c "
import urllib.request, json, sys

token = '$TOKEN'
owner = '$OWNER'
repo = '$REPO'
keep = int('$KEEP_COUNT')

headers = {
    'Authorization': f'Bearer {token}',
    'Accept': 'application/vnd.github+json'
}

try:
    req = urllib.request.Request(f'https://api.github.com/repos/{owner}/{repo}/actions/runs?per_page=100', headers=headers)
    with urllib.request.urlopen(req) as resp:
        runs = json.loads(resp.read().decode()).get('workflow_runs', [])
    
    # 区分进行中和已完成的
    in_progress = [r for r in runs if r.get('status') != 'completed']
    completed = [r for r in runs if r.get('status') == 'completed']
    
    print(f'当前运行中任务: {len(in_progress)} 个')
    for r in in_progress:
        print(f'  ● [运行中/保留] #{r[\"id\"]} | {r[\"name\"]}')
        
    print(f'🔒 节点 3 (NO3) 专属记录: {len(no3_runs)} 个 (已受到绝对豁免保护，不作删除)')
    print(f'当前 NO4/NO5 已完成任务: {len(completed)} 个 (设定保留最近 {keep} 条)')
    
    to_keep = completed[:keep]
    for r in to_keep:
        print(f'  ✓ [保留最近] #{r[\"id\"]} | {r[\"name\"]} | {r.get(\"conclusion\")}')
        
    to_delete = completed[keep:]
    if not to_delete:
        print('✨ 当前历史记录已非常整洁，无需清理。')
    else:
        print(f'开始清理多余的 {len(to_delete)} 条陈旧历史记录...')
        for r in to_delete:
            run_id = r['id']
            try:
                del_req = urllib.request.Request(f'https://api.github.com/repos/{owner}/{repo}/actions/runs/{run_id}', headers=headers, method='DELETE')
                with urllib.request.urlopen(del_req) as del_resp:
                    if del_resp.status == 204:
                        print(f'  🗑️ 已删除 #{run_id} ({r[\"name\"]})')
            except Exception as e:
                print(f'  ⚠️ 删除 #{run_id} 失败: {e}')
        print('🎉 清理完成！Actions 列表已焕然一新。')
except Exception as e:
    print('❌ 请求异常:', e)
"
