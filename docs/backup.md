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

1. 跑檢查腳本：

   ```bash
   ./scripts/check-secrets.sh ~/my-agent
   ```

   有警告就處理，冇警告先繼續。
2. 確認 repo 係私人：`gh repo view my-agent --json visibility --jq .visibility` 顯示 `PRIVATE`。
3. 睇一眼 `git status`，確認冇唔應該入嘅檔案。

## 幾時備份

- 每次收工之後（AI 更新完 `HANDOFF.md`）
- 最少每星期一次

```bash
cd ~/my-agent
git add -A
git commit -m "收工：日期＋一句做咗咩"
git push
```

## 千祈唔好放上 GitHub

- 密碼、API key、Token（放密碼管理器）
- 學生、客人、員工嘅個人資料
- 身份證、銀行、信用卡資料
- 合約或財務原件

## 萬一放咗

1. 即刻將 repo 設返私人。
2. 將洩露嘅密碼或 key **即刻作廢並重新申請**。刪檔案唔夠，因為 git 歷史仲有。
3. 個人資料洩露嘅話，按你行業嘅私隱規定處理。
