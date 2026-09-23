# Contributing

Run `bash scripts/check.sh` before you open a pull request.

- Keep the procedure in `SKILL.md`. Put catalogs in `references/`. One fact lives in one file.
- `SKILL.md` stays under 500 lines. `description` is one line, at most 500 characters, and says both what the skill does and when to use it.
- The `name` field matches the directory `cleanup-codebase`.
- A new detector command belongs in `references/detectors.md` and follows the install rule there: the binary is already present, and the command has no write flag.
- Do not add a network call to `scripts/inventory.sh`.
