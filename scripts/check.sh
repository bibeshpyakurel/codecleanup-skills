#!/usr/bin/env bash
# Validate the public skill package. Read-only aside from nothing: it does not edit the tree.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

skill="$root/.agents/skills/cleanup-codebase"
inventory="$skill/scripts/inventory.sh"

fail() {
  echo "check: $*" >&2
  exit 1
}

[[ -f "$skill/SKILL.md" ]] || fail "missing SKILL.md"
[[ -x "$inventory" ]] || fail "inventory.sh is not executable"
bash -n "$inventory"
bash -n "$root/scripts/check.sh"

for link in .claude/skills/cleanup-codebase .grok/skills/cleanup-codebase skills/cleanup-codebase; do
  [[ -L "$link" ]] || fail "$link is not a symlink"
  [[ -f "$link/SKILL.md" ]] || fail "$link does not resolve to SKILL.md"
done

python3 - "$skill/SKILL.md" << 'PY'
import pathlib, sys
text = pathlib.Path(sys.argv[1]).read_text()
if not text.startswith("---\n"):
    raise SystemExit("frontmatter missing")
end = text.index("\n---\n", 4)
front = text[4:end]
fields = {}
for line in front.splitlines():
    if not line.strip() or line.startswith(" "):
        continue
    key, value = line.split(":", 1)
    fields[key.strip()] = value.strip().strip('"')
name = fields["name"]
desc = fields["description"]
if name != "cleanup-codebase":
    raise SystemExit(f"name {name!r}")
if not (1 <= len(desc) <= 500) or "\n" in desc:
    raise SystemExit(f"description length {len(desc)}")
if 'version: "1.0.1"' not in front:
    raise SystemExit("metadata.version is not 1.0.1")
if len(text.splitlines()) > 500:
    raise SystemExit("SKILL.md exceeds 500 lines")
body_lines = text[end + 5 :].count("\n") + 1
for rel in (
    "references/aspects.md",
    "references/detectors.md",
    "references/false-alive.md",
    "references/policy.md",
    "scripts/inventory.sh",
    "agents/openai.yaml",
):
    path = pathlib.Path(sys.argv[1]).parent / rel
    if not path.exists():
        raise SystemExit(f"missing {rel}")
print(f"frontmatter ok ({len(desc)} chars, {body_lines} body lines)")
PY

report=$("$inventory" "$root/examples/orders")
printf '%s\n' "$report" | grep -q 'ecosystems' || fail "inventory missing ecosystems"
printf '%s\n' "$report" | grep -q -- '- javascript' || fail "fixture not detected as javascript"
printf '%s\n' "$report" | grep -q 'debug_leftovers: 1' || fail "expected one debug leftover"
printf '%s\n' "$report" | grep -q 'commented_code_candidates: 1' || fail "expected one commented-code candidate"
printf '%s\n' "$report" | grep -q 'tax.js.bak' || fail "backup file not listed"
printf '%s\n' "$report" | grep -q 'npm run test: node --test' || fail "package script not listed"

# The inventory must not flag its own source when pointed at the skill repo.
self=$("$inventory" "$root")
if printf '%s\n' "$self" | grep -q 'inventory.sh:'; then
  fail "inventory reported its own script"
fi

echo "check ok"
