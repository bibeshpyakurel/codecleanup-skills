# Landscape

Research notes for the `cleanup-codebase` skill. Surveyed in September 2026. The skill is the procedure; this file is the record of what already existed and which gaps it is built to close.

Release 1.0.0 does not install detectors. A tool runs only when the repository already has it. The library run below fetched Knip; that fetch is no longer part of the procedure.

## How a skill has to be packaged

Agent Skills is the open format: a directory with `SKILL.md` (YAML `name` and `description`, then Markdown), plus optional `scripts/`, `references/`, and `assets/`. The `name` matches the directory. Hosts load the description at startup and the body only when the skill triggers. The body should stay under about 500 lines, with detail one hop away in `references/`.

Sources: [agentskills.io specification](https://agentskills.io/specification), [Anthropic skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices).

Hosts differ on where they look and on description length:

| Host | Project path | Notes |
| --- | --- | --- |
| Grok | `.grok/skills/`, and also `.agents/skills/` and `.claude/skills/` | [Grok skills](https://x.ai/docs/build/features/skills-plugins-marketplaces) |
| Claude Code | `.claude/skills/` | Same SKILL.md format |
| Codex | `.agents/skills/` from the working directory up to the repo root, plus `~/.agents/skills/` | Symlinked skill folders are followed. Descriptions should stay short; older Codex docs cap `description` at 500 characters on one line. [Codex skills](https://developers.openai.com/codex/skills) |

The `skills` CLI treats `.agents/skills/` as the shared install location and searches `.claude/skills/`, `.grok/skills/`, and `skills/` when adding from a repo. [vercel-labs/skills](https://github.com/vercel-labs/skills).

This repo keeps one copy under `.agents/skills/cleanup-codebase/` and symlinks the Claude and Grok paths to it. The description is a single line under 500 characters so Codex will accept it. Grok-only keys (`when-to-use`, `metadata.short-description`) are extra frontmatter; other hosts ignore unknown keys.

## What cleanup skills already do

| Skill | What it is good at | What it leaves open |
| --- | --- | --- |
| [cleaning-up-codebases](https://jonesrussell.github.io/blog/building-codebase-cleanup-skill-claude-code/) (Russell Jones, Feb 2026) | "Should this exist?" before "how do I improve this?" Tiers from safe deletes to architecture. Baseline the build. Ask the owner before big cuts. | Language signals are a short list. Architecture (tier 4) is still in the execution path. No proof bar for dynamic use. |
| [ai-slop-cleaner](https://github.com/yeachan-heo/oh-my-claudecode) | Deletion before addition, one smell per pass, tests first, a fixed report. About 1.2k installs in a widely used repo. | Tied to oh-my-claudecode (Ralph, `--review`). No detector catalog. |
| [Knip skills](https://skills.sh/brianlovin/agent-config/knip) (about 2.4k installs) | Concrete unused files, exports, and dependencies for JS/TS. Configure before `--fix`. | One ecosystem. Blind `--allow-remove-files` deletes framework entry points. |
| [github/awesome-copilot refactor](https://skills.sh/github/awesome-copilot/refactor) (about 22k installs) | Behavior-preserving smell catalog: extract, rename, guard clauses. | A refactor skill. Extraction adds structure. That is not a cleanup. |
| [code-cleanup plugin](https://tonsofskills.com/plugins/code-cleanup/) (Jeremy Longshore) | Eleven dimensions, confidence, a green-test gate, specialist agents. | Claude-only (`AskUserQuestion`, eleven agents). Not a portable SKILL.md. |
| [ai-repo-cleanup](https://github.com/tiezhuli001/codex-skills/blob/main/skills/ai-repo-cleanup/SKILL.md) | Aggressive candidate discovery, conservative deletes, audit unless asked to edit. | Aimed at agent repositories. |
| [dead-code-sweep](https://github.com/petekp/agent-skills/tree/main/skills/dead-code-sweep) | Cruft left by agents that re-implement and forget the original. | Dead code only. |
| [repo-hygiene cleaning-existing-codebase](https://github.com/gg-mo/repo-hygiene/blob/main/skills/cleaning-existing-codebase/SKILL.md) | Survey, buy-in, small diffs. Warns against a 200-file hygiene mega-diff. | Depends on that repo's other skills. |
| [clean-code skill packs](https://github.com/btseee/clean-code-skills) | Writing standards for many hosts, including Grok. | "Leave it cleaner than you found it" causes drive-by edits during feature work. The opposite of a bounded cleanup. |

Shorter cousins exist (ClaudSkills' nine-category reporter, awesome-claude-code-toolkit's per-language dead-code command, `comment-cleanup`). They cover a slice and stop.

## What the detectors actually prove

Third-party tools are candidates. The failures below are why the skill forbids their write flags until the life checks pass.

- **Knip** builds a module graph from entry points and compares it to `package.json`. It finds unused files, exports, and dependencies in JS/TS. It is not a typechecker. Framework files, binaries used only from CI, and public entry exports are the usual false positives. [Knip: unused dependencies](https://knip.dev/typescript/unused-dependencies), [unused exports](https://knip.dev/typescript/unused-exports).
- **Ruff F401 / F841** finds unused imports and locals. The unused-import fix is unsafe in `__init__.py` re-exports. [Ruff F401](https://docs.astral.sh/ruff/rules/unused-import/).
- **Vulture** confidence 100 means unused within the analyzed files (arguments and unreachable code). Imports are 90. Functions and attributes are 60. [Vulture](https://github.com/jendrikseipp/vulture).
- **deptry** DEP002 is a declared dependency with no import. It does not flag dev dependencies, and it misses plugins loaded by name. [deptry rules](https://deptry.com/rules-violations/).
- **`deadcode`** (Go) reports functions not reachable from `main` or `init`. On a library module the exported API looks dead. [Go blog: Finding unreachable functions with deadcode](https://go.dev/blog/deadcode), [package docs](https://pkg.go.dev/golang.org/x/tools/cmd/deadcode).
- **`staticcheck`** still carries the unused analyzer for unexported code inside a package. It is not a whole-program public-API tool. [dominikh/go-tools](https://github.com/dominikh/go-tools).
- **`cargo machete`** is a text search, fast, and wrong for proc-macros and `build.rs`. `--fix` rewrites `Cargo.toml` including those false positives. **`cargo +nightly udeps`** uses compiler data and misses doc-tests. [cargo-machete](https://crates.io/crates/cargo-machete), [cargo-udeps](https://github.com/est31/cargo-udeps).
- **`mvn dependency:analyze`** reports unused declared dependencies and misses reflection and `META-INF/services`.

## The gap this skill fills

No portable skill found in the survey does all four of these together:

1. Every cleanup aspect, classified by whether an agent may edit it unprompted.
2. The project's own commands as the baseline, with third-party detectors as evidence rather than as `--fix`.
3. A life-check catalog for dynamic loads, framework files, public API, generated code, and migrations.
4. A report shape and a one-aspect batch loop that works in Grok, Claude, and Codex without host-specific tools.

The easy failure (delete a file nothing references, keep a plugin loaded by string concatenation) is one a careful agent already avoids on a tiny repo. The skill is aimed at the failures that survive that careful pass: shrinking a published export because nothing in-repo calls it, deleting a skipped test to make the suite look finished, inlining a config-driven handler because the tests still pass, and letting a detector's write flag outrun the search.

## Checked against a real agent

On 23 September 2026 an agent with no skill was given a six-file app and told to be thorough. It deleted an unreferenced module, a `.bak` file, commented-out code, a `console.log`, and an unused `left-pad` declaration. It kept a plugin loaded via `require("./plugins/" + pluginName)` and a comment that records a gateway timeout. Tests passed. Careful agents already get that case right.

A second agent, also with no skill, was given a published package (`@acme/orders`, with `main` and `exports`) and told to make it smaller, remove indirection and stale tests, and leave the tests passing. It did. It also deleted `formatInvoice` (exported, no in-repo caller), the config file that selected the `ship` handler, the `ECONNABORTED` retry branch, and a skipped test. `node --test` still passed: 1 passed, 0 skipped.

The same tree, cleaned with this skill under "Clean up this codebase" (`apply-proven`), removed `deprecatedQuote`, the debug `console.log`, the commented-out function, the `.bak` file, the narrating comment, and the `left-pad` declaration. `formatInvoice`, the handler config, the retry branch, and the skipped test stayed on the ledger. `node --test`: 1 passed, 1 skipped.
