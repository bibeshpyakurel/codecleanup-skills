# Security

`cleanup-codebase` is instruction text plus a read-only shell script. Installing it does not execute a cleanup. An agent executes the instructions only when a person invokes the skill or asks for a cleanup.

## What the instructions tell an agent to do

- Delete code only after a search and, when one is already installed, a detector agree that it is unused, and after the life checks in `references/false-alive.md`.
- Run linters and formatters the repository already configures.
- Leave published API, framework entry points, config-selected handlers, skipped tests, and applied migrations in place unless the person names that change.
- Report a suspected secret as a path and a kind. The report must not contain the secret. History rewriting is a separate request.

## What they tell an agent not to do

- Download or install a detector (`npx --yes`, `npm install`, `go install`, `cargo install`) during the cleanup.
- Add a dependency, upgrade one, or take a version change from `go mod tidy`.
- Use a detector's write flag (`knip --fix`, `cargo machete --fix`, remove-files flags).
- Edit a path listed under Protected paths in the target repository's `CLEANUP.md`.
- Commit, push, or open a pull request unless the person asked.

## The inventory script

`scripts/inventory.sh` is read-only. It takes a repository path, walks source files, and prints counts. It does not use the network and it does not delete. Review it before you run it; it is plain bash.

## Reporting a problem

Open an issue on this repository if the instructions can be read as permission to exfiltrate data, run untrusted code, or delete live code. Include the skill version and the sentence in `SKILL.md` that allows the behavior.
