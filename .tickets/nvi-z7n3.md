---
id: nvi-z7n3
status: open
deps: []
links: []
created: 2026-09-29T11:52:39Z
type: task
priority: 2
assignee: Alexander Q
tags: [rest, kulala]
---
# kulala.nvim upstream gone: monitor, then fork vs replace

[mistweaverco/kulala.nvim](https://github.com/mistweaverco/kulala.nvim) went private on 2026-09-26; as of 2026-09-29 both it and [mistweaverco/kulala-core](https://github.com/mistweaverco/kulala-core) return 404. lua/plugins/90-rest.lua runs [lattenwald/kulala.nvim](https://github.com/lattenwald/kulala.nvim) (branch mistweaverco-main, pinned dcad056) with kulala_core.path set to the local binary (0.37.0), since newer kulala.nvim commits need kulala-core 1.x, which is unavailable. GitHub now lists the fork's parent as [t-eichmann/kulala.nvim](https://github.com/t-eichmann/kulala.nvim), a stale mirror (last push 2024-06-29).

## Design

Monitor: check whether mistweaverco/kulala.nvim and kulala-core come back (public again, or relocated), and under what license/terms.

Options:
- Hand-rolled plugin: current first choice unless kulala returns soon. Scope to what's actually used: the <leader>R keymaps in 90-rest.lua on .http files.
- Keep the own fork: frozen at dcad056 with kulala-core 0.37.0; no upstream fixes, and the core binary can't be re-fetched if lost.
- Switch to an existing alternative (e.g. rest.nvim, which this config used before acc21ca).

## Acceptance Criteria

Upstream status recorded; option chosen; 90-rest.lua uses the chosen option and no longer depends on the fork or the pinned kulala-core binary (unless keeping the fork is the decision).

