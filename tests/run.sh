#!/bin/bash
set -uo pipefail
cd "$(dirname "$0")/.."
PASS=0; FAIL=0
ok(){ echo "  ✅ $1"; PASS=$((PASS+1)); }
bad(){ echo "  ❌ $1"; FAIL=$((FAIL+1)); }
echo ""; echo "  @deepwhale-cn/dsh-cn-mlps · 双向验证"
echo "  ────────────────────────────────────────────────"
echo ""; echo "  【正例】违规样本（必须报）"
N=$(node bin/cli.mjs --root tests/fixtures/fail/demo-project --quiet 2>&1 | grep -oE '^[0-9]+' | head -1)
[ "${N:-0}" -ge 5 ] && ok "命中 ${N} 条（≥5）" || bad "只命中 ${N} 条"
J=$(node bin/cli.mjs --root tests/fixtures/fail/demo-project --json 2>&1)
for rid in MLPS-DEFAULT-CRED MLPS-WEAK-HASH MLPS-PLAINTEXT MLPS-DEBUG MLPS-ERROR-LEAK; do
  c=$(echo "$J" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(len([f for f in d['findings'] if f['ruleId']=='$rid']))" 2>/dev/null)
  [ "${c:-0}" -gt 0 ] && ok "$rid 报出（${c} 条）" || bad "$rid 未报出"
done
echo ""; echo "  【反例】合规样本（必须 0 命中）"
M=$(node bin/cli.mjs --root tests/fixtures/pass/clean-project --quiet 2>&1 | grep -oE '^[0-9]+' | head -1)
[ "${M:-1}" = "0" ] && ok "0 命中" || bad "误报 ${M} 条"
echo ""; echo "  【回归】上下文不明的 md5 不该报（etag 用例）"
E=$(echo "$J" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(len([f for f in d['findings'] if f['ruleId']=='MLPS-WEAK-HASH' and 'etag' in (f.get('excerpt') or '')]))" 2>/dev/null)
[ "${E:-1}" = "0" ] && ok "md5(p) 未误报" || bad "md5(p) 被误报"
echo ""; echo "  【溯源】每条规则必须带 source"
python3 - <<'PY' && ok "全部规则均有 source" || bad "有规则缺 source"
import json,glob,sys
for f in glob.glob('rules/*.json'):
    r=json.load(open(f,encoding='utf-8'))
    if not r.get('source'): print('缺:',r.get('id'),file=sys.stderr); sys.exit(1)
PY
echo ""; echo "  【溯源格式】source 必须用章节名，不得编造条款编号"
if grep -rqE '"?source"?.*[0-9]+\.[0-9]+\.[0-9]+' rules/ 2>/dev/null; then
  bad "有规则写了条款编号（无法核实，属编造风险）"
else
  ok "全部只用章节名"
fi
echo ""; echo "  ────────────────────────────────────────────────"
echo "  通过 $PASS · 失败 $FAIL"; echo ""
[ "$FAIL" -eq 0 ] || exit 1
