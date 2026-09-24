---
id: nvi-u34b
status: open
deps: []
links: []
created: 2026-09-23T10:13:11Z
type: task
priority: 3
assignee: Alexander Q
tags: [ai, claudecode]
---
# Move Claude Code into the TUI helpers (ai_helpers)

Split AI integrations into two families: TUI tools via ai_helpers (Claude Code joining Codex, OpenCode, etc.) and ACP via agentic.nvim (lua/plugins/30-agentic.lua). Deferred until the ACP trial shows how the two families should divide the work.

## Design

Open question: what happens to claudecode.nvim.
- Keep bridge only: claudecode.nvim keeps its websocket bridge with terminal provider "none"; ai_helpers launches claude connected to it. Diff review (hs/hr, <leader>ha/hd), selection/@-mention sending and diagnostics keep working.
- Drop claudecode.nvim: claude becomes a plain helper; lose the diff review, the claudecode selection/@-mention sending, and diagnostics; ACP side covers those instead.
- Leave as is, if ACP ends up replacing the Claude TUI use.

## Findings (2026-09-24)

Bridge-only works: plain claude in a snacks terminal joined claudecode.nvim's bridge and saw nvim's LSP diagnostics.
- Discovery: claudecode.nvim writes ~/.claude/ide/<port>.lock (pid, workspaceFolders, ideName "Neovim"); claude joins the lock whose workspace matches its cwd and rejects others ("workspace or project directories don't match").
- Load order: claudecode.nvim is lazy (keys only). Before it loads there is no lock, so /ide shows no IDE; after :Lazy load claudecode.nvim it appears. The helper must load claudecode.nvim before spawning claude.
- Auto-connect differs per account: ~/.claude-personal/.claude.json has autoConnectIde: true (connected without /ide); the work account didn't auto-connect and needed /ide.
- claudecode.nvim's own terminal sets CLAUDE_CODE_SSE_PORT=<port> and ENABLE_IDE_INTEGRATION=true; the snacks-launched claude had neither and relied on cwd matching.
- Two claude clients on one bridge work (claudecode terminal + snacks terminal in the same nvim).

Plan for the helper: ensure claudecode.nvim is loaded, then launch `claude --ide` with CLAUDE_CODE_SSE_PORT set to this nvim's bridge port (pins the right instance when two nvims share a cwd; account-independent). Port the account switcher's CLAUDE_CONFIG_DIR + sync-personal-links.sh into the helper env.
Untested: selection tracking and openDiff (hs/<leader>wa/<leader>wd) through the helper-launched claude; two nvims with the same cwd.

## Acceptance Criteria

Claude Code launches and toggles through ai_helpers like the other helpers; the chosen claudecode.nvim option is applied and documented.

