#!/usr/bin/env bash
# Initialise the local .company-skill workspace in the current repository.
# LOCAL ONLY - the created tree must never be committed.
#
# Usage:  bash init-company-skill.sh <SkillDir> [RepoName ...]
#   <SkillDir>  path to this skill (the folder containing templates/)
#   [RepoName]  repositories to seed, e.g. ServiceA ServiceB

set -euo pipefail

SKILL_DIR="${1:?usage: init-company-skill.sh <SkillDir> [RepoName ...]}"
shift || true
TPL="$SKILL_DIR/templates"
ROOT=".company-skill"

if [ ! -d "$TPL" ]; then
  echo "templates/ not found under $SKILL_DIR" >&2
  exit 1
fi

mkdir -p "$ROOT/memory/global" "$ROOT/memory/shared" "$ROOT/memory/repositories" \
         "$ROOT/issues" "$ROOT/temp"

copy_if_absent() { [ -f "$2" ] || cp "$1" "$2"; }

for f in "$TPL"/memory/global/*.md;  do copy_if_absent "$f" "$ROOT/memory/global/$(basename "$f")"; done
for f in "$TPL"/memory/shared/*.md;  do copy_if_absent "$f" "$ROOT/memory/shared/$(basename "$f")"; done

copy_if_absent "$TPL/unknowns.md"    "$ROOT/unknowns.md"
copy_if_absent "$TPL/corrections.md" "$ROOT/corrections.md"

for repo in "$@"; do
  mkdir -p "$ROOT/memory/repositories/$repo"
  for f in "$TPL"/memory/repositories/_REPO_TEMPLATE/*.md; do
    target="$ROOT/memory/repositories/$repo/$(basename "$f")"
    if [ ! -f "$target" ]; then
      sed "s/<RepoName>/$repo/g" "$f" > "$target"
    fi
  done
  echo "seeded repository memory: $repo"
done

# .company-skill must never be committed.
# Use .git/info/exclude (local, never committed) - NOT .gitignore, so installing
# the skill produces zero diff in the repository.
if EXCLUDE="$(git rev-parse --git-path info/exclude 2>/dev/null)"; then
  mkdir -p "$(dirname "$EXCLUDE")"
  touch "$EXCLUDE"
  grep -qxF '.company-skill/' "$EXCLUDE" || printf '\n.company-skill/\n' >> "$EXCLUDE"
  echo "excluded via $EXCLUDE"
else
  echo "WARNING: not a git repository - add '.company-skill/' to .git/info/exclude once it is." >&2
fi

echo "done. .company-skill/ initialised (local only, .gitignore untouched)."
echo "NOTE: existing files were never overwritten."
