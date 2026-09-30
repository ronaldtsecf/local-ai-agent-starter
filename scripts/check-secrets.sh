#!/bin/bash
# 推上 GitHub 之前，掃一次「會被推上去」嘅檔案，搵明顯嘅密碼、key 同個人資料。
# 用法：./scripts/check-secrets.sh ~/my-agent
#
# 呢個係基本檢查，唔係安全證明：
#   - 只掃文字檔；PDF、Excel、Word、圖片掃唔到（會列出嚟叫你人手睇）
#   - 唔識中文人名、學生成績呢類內容
#   - 為免將密碼再印出嚟，警告只顯示檔名、行數同類型，唔顯示內容
# 跑完仍然要自己睇 `git status` 同 `git diff --cached`。

DIR="${1:-.}"
[ -d "$DIR" ] || { echo "搵唔到資料夾：$DIR"; exit 2; }

warn=0
manual=""

# 1. 收集「會被推上 GitHub」嘅檔案（有 git 就跟 git，冇就全部）
if git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  FILES=$(git -C "$DIR" -c core.quotepath=off ls-files --cached --others --exclude-standard)
  echo "掃描範圍：git 會追蹤或準備追蹤嘅檔案（已被 .gitignore 擋嘅唔會推，所以唔掃）"
  HAS_GIT=1
else
  FILES=$(cd "$DIR" && find . -type f -not -path './.git/*' | sed 's#^\./##')
  echo "掃描範圍：資料夾內所有檔案（未 git init）"
  HAS_GIT=0
fi

# 2. 規則：「名稱|正則」
RULES=(
"疑似 API key／Token|((^|[^A-Za-z0-9_-])sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{30,}|eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{15,})"
"疑似私鑰|-----BEGIN [A-Z ]*PRIVATE KEY-----"
"疑似密碼／密鑰賦值|(password|passwd|pwd|secret|token|api[_ -]?key|密碼|密码|口令)[[:space:]]*(\"|'|“|”)?[[:space:]]*(:|=|：|＝|是|係)[[:space:]]*(\"|'|“|”)?[A-Za-z0-9!@#$%^&*._+/=-]{6,}"
"疑似香港電話|((\+852|852)[ -]?|電話|手機|whatsapp|(^|[^A-Za-z])(tel|phone|mobile))[^0-9]{0,6}[2-9][0-9]{3}[ -]?[0-9]{4}"
"疑似香港手機（空格分隔）|(^|[^0-9])[569][0-9]{3} [0-9]{4}([^0-9]|$)"
"疑似香港身份證|[A-Z]{1,2}[0-9]{6}(\(|（)[0-9A](\)|）)|(^|[^A-Za-z0-9])[A-Z]{1,2}[0-9]{7}([^0-9]|$)"
"疑似電郵地址|[A-Za-z0-9._%+-]+[@＠][A-Za-z0-9.-]+\.[A-Za-z]{2,}"
"疑似銀行戶口號碼|[0-9]{3}-[0-9]{6}-[0-9]{3}"
"疑似信用卡號碼|[0-9]{4}[ -][0-9]{4}[ -][0-9]{4}[ -][0-9]{4}"
)

# 3. 逐個檔案掃
while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in scripts/check-secrets.sh) continue ;; esac   # 唔掃自己
  path="$DIR/$f"
  [ -f "$path" ] || continue
  lower=$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')

  # 唔應該備份嘅檔名
  case "$lower" in
    *.env|.env|.env.*|*/.env|*/.env.*|*.pem|*.key|*.p12|*id_rsa*|*credential*|*secret*|*token*)
      echo "⚠️  唔應該備份嘅檔名：$f"; warn=1 ;;
  esac

  # 掃唔到內容嘅檔案類型 → 人手檢查
  case "$lower" in
    *.pdf|*.xlsx|*.xls|*.docx|*.doc|*.pptx|*.ppt|*.zip|*.png|*.jpg|*.jpeg|*.heic|*.mp3|*.mp4|*.mov)
      manual="$manual
     $f"
      continue ;;
  esac

  for rule in "${RULES[@]}"; do
    label="${rule%%|*}"
    pattern="${rule#*|}"
    lines=$(grep -nEIi -e "$pattern" "$path" 2>/dev/null | cut -d: -f1 | head -5 | tr '\n' ',' | sed 's/,$//')
    if [ -n "$lines" ]; then
      echo "⚠️  ${label}：${f}（第 $lines 行）"
      warn=1
    fi
  done
done <<< "$FILES"

# 4. git 歷史：key 一旦入過歷史，刪咗檔案都仲喺
if [ "$HAS_GIT" -eq 1 ]; then
  hist=$(git -C "$DIR" log -p --all 2>/dev/null | grep -Ec -e '((^|[^A-Za-z0-9_-])sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{15,}|-----BEGIN [A-Z ]*PRIVATE KEY-----)')
  if [ "${hist:-0}" -gt 0 ]; then
    echo "⚠️  git 歷史入面有 $hist 處疑似 key。即使而家個檔案冇咗，推上 GitHub 之後人人睇到歷史。"
    echo "     要當作已洩露：先去原服務作廢並重新申請，再處理歷史。"
    echo "     如果係全新、未推上 GitHub 嘅資料夾，最簡單係刪走 .git 再重新 git init（做之前要先問用戶批准）。"
    warn=1
  fi
fi

# 5. 掃唔到嘅檔案
if [ -n "$manual" ]; then
  echo ""
  echo "👀 以下檔案我掃唔到內容，推之前請人手確認冇學生、客人或財務資料："
  echo "$manual" | head -15
fi

echo ""
if [ "$warn" -eq 0 ]; then
  echo "✅ 冇發現我掃得到嘅問題。"
  echo "   呢個唔代表安全：我只掃文字檔，唔識中文人名同成績呢類內容。"
  echo "   推之前請自己睇一次 git status 同 git diff --cached。"
  exit 0
else
  echo "❌ 有警告。逐個處理咗先好推上 GitHub。"
  exit 1
fi
