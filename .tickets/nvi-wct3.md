---
id: nvi-wct3
status: open
deps: []
links: []
created: 2026-09-23T09:12:03Z
type: feature
priority: 3
assignee: Alexander Q
tags: [mason, npm, draft]
---
# Mason: fall back to mirror's latest npm version when registry version is missing

Mason updates for npm packages fail with ETARGET when the mason registry references a version the npm mirror (nexus.int.rclabenv.com, ~5-6 day min-age lag) doesn't have yet. Example: bash-language-server@5.8.1 on 2026-09-23 while mirror's newest was 5.8.0. Status: design draft only — not yet decided whether this is a good idea. Alternative is to just wait for the mirror or pin manually (:MasonInstall pkg@ver).

## Design

Rejected: pinning mason-registry to an older release tag (lags all sources, not only npm); npm --before (mason requests exact versions, so it has no effect).

Draft: wrap Package:install in the mason spec (lua/plugins/55-lsp.lua).
- Only for packages whose spec source id is pkg:npm/..., and only when opts.version is unset.
- Check mirror: npm view <pkg>@<ver> version. If empty, set opts.version = npm view <pkg> version (mirror latest).
- Receipt then records the actual installed version, so Mason keeps showing it as outdated and updates normally once the mirror catches up.
- Notify when falling back.

Concerns to decide on:
- Monkeypatches a mason internal; must fail loudly (no silent fallback) if Package:install/spec shape changes.
- Synchronous npm view (~1s) per npm install/update blocks the UI; consider async or accept it.
- Is it worth it vs. waiting ~5 days?

## Acceptance Criteria

npm package update succeeds with mirror's latest when registry version is absent; non-npm packages unaffected; package still shown outdated until mirror has registry version; breaks loudly on mason API change.

