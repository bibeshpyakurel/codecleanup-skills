# Changelog

## 1.0.1

- A `console.log` that reports progress stays. Only a debug marker (`console.debug`, `debugger`, `dbg!`, a log whose message says debug, and the same family in Python and Ruby) is a proven delete.
- Comment lines that start with ordinary words such as "private" or "let" are no longer commented-out-code candidates.
- Inventory finds manifests nested below the repository root, so a backend or frontend package is not invisible.

## 1.0.0

First public release.

- Behavior-preserving cleanup for Claude, Codex, Grok, Cursor, and any host that reads Agent Skills.
- Proven, mechanical, judgment, and out-of-scope classes.
- Life checks for dynamic loads, framework files, and published exports.
- Detectors run only when already installed. No network install during a cleanup.
- Optional `CLEANUP.md` for protected paths, required commands, and a batch limit.
- Read-only `inventory.sh`, fixture check, and GitHub Actions.
