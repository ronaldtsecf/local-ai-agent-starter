#!/bin/bash
# 推上 GitHub 之前，掃一次資料夾有冇明顯嘅密碼、key 同個人資料。
# 用法：./scripts/check-secrets.sh ~/my-agent
# 呢個係基本檢查，唔保證掃晒所有嘢；重要資料仍要自己睇。

DIR="${1:-.}"
[ -d "$DIR" ] || { echo "搵唔到資料夾：$DIR"; exit 2; }

found=0
scan() {
  local label="$1" pattern="$2"
  local hits
  hits=$(grep -rEIn --exclude-dir=.git --exclude-dir=node_modules -e "$pattern" "$DIR" 2>/dev/null | head -5)
  if [ -n "$hits" ]; then
    echo "⚠️  $label"
    echo "$hits" | sed 's/^/     /'
    found=1
  fi
}

scan "疑似 API key／Token"        '(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{30,})'
scan "疑似私鑰"                    '-----BEGIN [A-Z ]*PRIVATE KEY-----'
scan "疑似密碼賦值"                '(password|passwd|secret|token|api[_-]?key)[[:space:]]*[:=][[:space:]]*["'\'']?[A-Za-z0-9/+_-]{8,}'
scan "疑似香港電話／手機號碼"       '(^|[^0-9])(\+?852[ -]?)?[2-9][0-9]{3}[ -]?[0-9]{4}([^0-9]|$)'
scan "疑似身份證號碼"              '[A-Z]{1,2}[0-9]{6}\([0-9A]\)'
scan "疑似電郵地址"                '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'

# 唔應該存在嘅檔案類型
bad=$(find "$DIR" -not -path '*/.git/*' \( -name '.env' -o -name '.env.*' -o -name '*.pem' -o -name '*.key' -o -name 'credentials*' \) 2>/dev/null | head -5)
if [ -n "$bad" ]; then
  echo "⚠️  發現唔應該備份嘅檔案"
  echo "$bad" | sed 's/^/     /'
  found=1
fi

if [ "$found" -eq 0 ]; then
  echo "✅ 冇發現明顯問題（呢個只係基本檢查）"
  exit 0
else
  echo ""
  echo "❌ 有警告。處理咗先好推上 GitHub。"
  exit 1
fi
