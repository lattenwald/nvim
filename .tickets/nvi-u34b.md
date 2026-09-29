---
id: nvi-u34b
status: in_progress
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

## Decision (2026-09-29)

Drop claudecode.nvim; the bridge-only plan above is superseded. Trial running with the plugin inactive.
- Diff review: never used.
- Sending: helper sends produce the same `@file#L…` mentions.
- Selection tracking: no known use.
- Diagnostics: the bridge's getDiagnostics returned the same 16 lua_ls warnings as standalone `lua-language-server --check=.` (standalone also found 5 unused-local hints the bridge omitted), plus 52 Harper prose hints. Standalone lua_ls gives Claude at least as much.

Done:
- 3057990: helper prefs moved from ai_helpers.json to ai_helpers.yaml; shared `utils.save_yaml`.
- fed65f2: `claude_code` helper (named "Claude Code (work)" when ~/.claude-personal exists) and `claude_personal` (CLAUDE_CONFIG_DIR + sync-personal-links.sh via `before_spawn`); `<leader>wb`/`<leader>ws` send to helpers.
- claudecode.nvim spec set to `cond = false`: not loaded, but lazy keeps it installed and pinned.

Lost during the trial: `<C-,>`/`<leader>,` direct Claude toggles, `--resume`/`--continue` keys (helpers can't take per-call args), `ClaudeCodeTreeAdd` from file trees, `:ClaudeAccount` (replaced by picking the helper).

After the trial, remove:
- the claudecode.nvim spec (30-ai.lua) and its lazy-lock entry;
- claudecode-only code in ai_helpers.lua: `sub`, `apply_sub`, `run_claude`, `claude_select_account`, `claude_toggle`, `kill_claude_terminal`, `route_send`, `smart_send_*`, `cc_bufnr`/`is_claudecode_visible`, and the "claude" case in `hide_agent_terminals`/`agent_for_buf`;
- opencode's `OPENCODE_EDITOR_SSE_PORT = "1"` workaround, which only exists to dodge claudecode's lock files.
Keep `M.claude_has_personal_config` (used by 30-agentic.lua).

## Acceptance Criteria

Claude Code launches and toggles through ai_helpers like the other helpers; the chosen claudecode.nvim option is applied and documented.

