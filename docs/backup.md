# 私人 GitHub 備份

## 點解用 GitHub 私人 repo

- 有歷史版本，改錯咗可以還原。
- 換電腦，一句 `gh repo clone` 就攞返。
- 私人 repo 只有你（同你授權嘅人）睇到。

**唔建議用 iCloud、Google Drive 同步呢個資料夾：** 自動同步可能製造衝突副本（例如 `xxx (Conflicted).md`），搞亂 AI 嘅守則同版本紀錄。

## GitHub 唔係完整備份

GitHub 唔會自動包含：未提交嘅檔案、被 `.gitignore` 排除嘅檔案、太大嘅檔案。
所以：**重要嘅大檔案，另外用 Time Machine 或者外置硬碟備份。**

## 備份前檢查（每次推之前）

1. 跑檢查腳本（起資料夾時已經複製咗一份入你嘅資料夾）：

   ```bash
   cd ~/my-agent && ./scripts/check-secrets.sh .
   ```

   有警告就處理。腳本只顯示檔名同行數，唔顯示密碼內容。
   **冇警告唔等於安全**：腳本只掃文字檔，掃唔到 PDF、Excel、Word，亦唔識中文人名或成績。列出嚟嘅檔案要你人手睇。
2. 確認 repo 係私人：`gh repo view my-agent --json visibility --jq .visibility` 顯示 `PRIVATE`。
3. 睇 `git status --short`，逐個揀今次要備份嘅檔案，再用完整檔名 stage。例如第一次備份可以逐項確認後用：

   ```bash
   git add -- AGENTS.md CLAUDE.md MEMORY.md HANDOFF.md .gitignore scripts/check-secrets.sh skills/README.md memory/.gitkeep skills/.gitkeep projects/.gitkeep inbox/.gitkeep
   ```

   往後有新記憶或項目檔，就將佢哋嘅確實路徑加入清單；唔好用 `git add -A`、`git add .` 或成個資料夾一併收晒。先睇 `git diff --cached --name-status` 同 `git diff --cached`，確認 staged 清單同內容正正係你批准嘅範圍。已 stage 嘅舊檔亦會一齊提交，見到唔明嘅 staged 檔就停低查清楚。

## 幾時備份

- 每次收工之後（AI 更新完 `HANDOFF.md`）
- 最少每星期一次

```bash
cd ~/my-agent
# 先完成上面嘅掃描、顯式 stage 同內容確認
git commit -m "收工：日期＋一句做咗咩"
git push
git rev-parse HEAD
git ls-remote origin refs/heads/main
```

最後兩個 commit 編號一致，先算呢次已推上備份；`git status --short` 仲有檔案就代表嗰啲未包含，唔好當成全部已備份。

## 千祈唔好放上 GitHub

- 密碼、API key、Token（放密碼管理器）
- 學生、客人、員工嘅個人資料
- 身份證、銀行、信用卡資料
- 合約或財務原件

## 萬一放咗

1. 即刻將 repo 設返私人。
2. 將洩露嘅密碼或 key **即刻作廢並重新申請**。刪檔案唔夠，因為 git 歷史仲有。
3. 個人資料洩露嘅話，按你行業嘅私隱規定處理。
