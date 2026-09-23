# Cleanup Codebase

An agent skill for Claude, Codex, Grok, and Cursor that cleans dead code, unused dependencies, debug leftovers, and repository cruft without changing behavior.

```bash
npx skills add bibeshpyakurel/codecleanup-skills --skill cleanup-codebase
```

That installs [Agent Skills](https://agentskills.io/specification)-compatible instructions. Ask the agent to clean up the codebase, or invoke `/cleanup-codebase` (Claude, Grok) or `$cleanup-codebase` (Codex). Ask for an audit — "what should we clean, don't change anything" — to get the ledger with no edits.

The same folder works in any host that reads `SKILL.md`, including the 70+ agents supported by the [skills CLI](https://github.com/vercel-labs/skills). [skills.sh](https://skills.sh) lists a repository after people install it.

## What a run is allowed to change

| Class | On "clean up this codebase" |
| --- | --- |
| Proven | Deleted, with a citation. Unreferenced private code, commented-out code, narrating comments, backup files, debug statements, unused direct dependencies. |
| Mechanical | Fixed by the project's own linter or formatter. |
| Judgment | Reported. Edited only when you name the change or ask for refactors, and only where tests already cover the behavior. Duplication, registries, naming, complexity, types, swallowed errors, TODOs, docs that contradict the code. |
| Out of scope | Reported and left alone. Skipped or failing tests, secrets, dependency upgrades, architecture, drive-by bugfixes. |

A published export with no in-repo callers stays on the ledger. So does a handler loaded by a config string, a framework route, or an applied migration. Detectors run only when they are already installed. A cleanup does not `npx` a new tool, upgrade a dependency, or rewrite git history.

The procedure is [`.agents/skills/cleanup-codebase/SKILL.md`](.agents/skills/cleanup-codebase/SKILL.md). Aspect classes, detector commands, life checks, and the org policy format are in [`references/`](.agents/skills/cleanup-codebase/references).

## Install for one agent

| Agent | Project path | User path |
| --- | --- | --- |
| Codex, Cursor, and other Agent Skills hosts | `.agents/skills/cleanup-codebase` | `~/.agents/skills/cleanup-codebase` |
| Claude Code | `.claude/skills/cleanup-codebase` | `~/.claude/skills/cleanup-codebase` |
| Grok | `.grok/skills/cleanup-codebase` or `.agents/skills/cleanup-codebase` | `~/.grok/skills/cleanup-codebase` |

`npx skills add` writes the copy and the per-agent links for you. To pin a checkout of this repository instead, copy `.agents/skills/cleanup-codebase` into one of those paths.

## Enterprise controls

A `CLEANUP.md` at the root of the repository being cleaned sets protected paths, extra commands that must pass, and a file limit per batch. The default limit is 20 files. The shape is [references/policy.md](.agents/skills/cleanup-codebase/references/policy.md). This repository's own [`CLEANUP.md`](CLEANUP.md) protects `examples/**`.

Each run ends with a report: scope and skill version, baseline, applied batches with proof, the remaining ledger, verification commands, and what was not verified. Commit or open a pull request only when the person who asked for the cleanup says so.

## Security

The trust model is in [SECURITY.md](SECURITY.md). The skill instructs an agent to delete code. Read that page before you run it against a monorepo you do not own.

## Design notes

[docs/landscape.md](docs/landscape.md) records the skills and detectors this package was built against, and the two agent runs used to check it: one that kept a string-loaded plugin, and one that deleted a published export, a config-selected handler, a retry branch, and a skipped test while the tests still passed.

## Development

```bash
bash scripts/check.sh
```

The check validates frontmatter, symlinks, and the inventory script against [`examples/orders`](examples/orders). GitHub Actions runs the same script.

## License

[MIT](LICENSE). Copyright 2026 Bibesh Pyakurel.
