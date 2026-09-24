---
id: nvi-wct3
status: closed
deps: []
links: []
created: 2026-09-23T09:12:03Z
type: feature
priority: 3
assignee: Alexander Q
tags: [mason, npm]
---
# Mason: fall back to mirror's latest npm version when registry version is missing

Mason updates for npm packages fail with ETARGET when the mason registry references a version the npm mirror (nexus.int.rclabenv.com; lags unevenly per package, cause unconfirmed — likely per-package metadata caching, not a fixed min-age) doesn't have yet. Example: bash-language-server@5.8.1 on 2026-09-23 while mirror's newest was 5.8.0.

## Design

Rejected: pinning mason-registry to an older release tag (lags all sources, not only npm); npm --before (mason requests exact versions, so it has no effect); wrapping Package:install (must return a handle synchronously, so the mirror check would block the UI).

Implemented in lua/config/mason_npm_fallback.lua, called from the mason spec config in lua/plugins/55-lsp.lua:
- Wraps install() of mason's npm compiler (mason-core.installer.compiler.compilers.npm), which runs async inside the install runner — no UI blocking.
- Skipped when opts.version is set, so an explicit :MasonInstall pkg@ver still fails if the mirror lacks it.
- npm view <pkg>@<ver> version; only on E404 falls back to npm view <pkg> version (mirror latest). Other npm errors pass through unchanged.
- Sets source.version and purl.version, so the receipt records the installed version and Mason keeps showing the package outdated until the mirror catches up.
- Warns via stderr in the install log and vim.notify.
- Asserts on the compiler's install() and source shape, so a mason API change fails the install loudly instead of silently skipping the fallback.

Known behavior (accepted): a manual update while the mirror still lacks the registry version reinstalls the mirror's latest again (~10s, harmless). Failing with a message instead would mark every update red in :Mason. Auto-install via utils.mason_install skips installed packages, so it is unaffected.

Layout: own module in lua/config/ rather than utils.lua — temporary, single-caller patch on mason internals; removal is deleting the file and one line in 55-lsp.lua.

## Acceptance Criteria

npm package update succeeds with mirror's latest when registry version is absent; non-npm packages unaffected; package still shown outdated until mirror has registry version; breaks loudly on mason API change.

Verified 2026-09-24: bash-language-server update installed 5.8.0 (registry 5.8.1) with the warning notification; receipt records pkg:npm/bash-language-server@5.8.0.
