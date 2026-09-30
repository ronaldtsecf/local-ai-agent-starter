# 帳號出事之後：復活 SOP

假設：你原本用緊 AI-A，佢而家用唔到（帳號被停、額度冇、服務改咗）。你嘅資料夾仲喺你電腦或者私人 GitHub。

## 第 0 步：先唔好慌，確認資料夾仲喺

```bash
ls ~/my-agent
```

見到 `AGENTS.md`、`HANDOFF.md`、`MEMORY.md` 就得。電腦都壞咗嘅話，跳去第 4 步。

## 第 1 步：搵一隻新 AI

- 開新帳號同一間公司；或者
- 轉用另一間（例如 Claude Code ↔ Codex，或者其他）。

呢一步要你自己做（開帳號、付費、登入），冇 AI 可以代你做。

## 第 2 步：開資料夾，叫新 AI 接手

```bash
cd ~/my-agent
# 開你新嘅 AI（claude 或 codex）
```

對新 AI 講：

> 我而家換咗 AI。請先讀 `AGENTS.md`，再讀 `HANDOFF.md` 同 `MEMORY.md`。讀完之後，用你自己嘅話講：我係邊個、我有咩紅線、而家做緊咩、下一步係咩。

## 第 3 步：做接手測試

跟 [handoff-test.md](handoff-test.md)。三條都過，先當復活成功。

## 第 4 步：電腦都壞咗

1. 喺新電腦裝好 AI 工具。
2. 由你嘅私人 GitHub 攞返資料夾。要先有 `gh`（GitHub 指令工具，去 https://cli.github.com 下載 Mac 安裝檔）：

   ```bash
   gh auth login        # 你自己登入
   gh repo clone my-agent ~/my-agent
   ```

3. 返去第 2 步。

## 第 5 步：修補洞

復活過程中，如果新 AI 有嘢唔明：

1. 記低邊度唔明。
2. 修 `AGENTS.md` 或 `HANDOFF.md`。
3. 再做一次接手測試。

## 要有心理準備

- 新 AI 唔會同舊嗰隻一模一樣。有啲位可能要你重新校正。
- 如果你太耐冇推備份，最近嘅記憶可能冇。所以每星期推一次。
- 你一定要先有一隻可用嘅 AI（新帳號或者另一間），呢個包幫唔到你免除呢一步。
