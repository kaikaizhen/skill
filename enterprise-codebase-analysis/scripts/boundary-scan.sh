#!/usr/bin/env bash
# Engine / workspace boundary scan. Lists lines in the reusable engine (SKILL.md,
# references/, templates/, scripts/) that match the organization's marker terms.
# The terms are organization facts, so they live in the workspace:
#   workspace/references/boundary-terms.txt   (one extended regex per line;
#   '#' comments; 'allow:<regex>' drops matching result lines as accepted)
# Exit 0 = clean, 1 = hits to classify (references/boundary.md), 2 = no term file.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TERMS="$ROOT/workspace/references/boundary-terms.txt"
[ -f "$TERMS" ] || { echo "no term file: $TERMS (engine cannot be scanned)"; exit 2; }
PAT=$(grep -v -E '^(#|allow:|$)' "$TERMS" | paste -sd'|' -)
ALLOW=$(grep -E '^allow:' "$TERMS" | sed 's/^allow://' | paste -sd'|' -)
cd "$ROOT" || exit 2
OUT=$(grep -rn -I -E "$PAT" SKILL.md references templates scripts \
      --exclude-dir=legacy --exclude=boundary-scan.sh 2>/dev/null)
[ -n "$ALLOW" ] && OUT=$(printf '%s\n' "$OUT" | grep -v -E "$ALLOW")
OUT=$(printf '%s\n' "$OUT" | sed '/^$/d')
if [ -z "$OUT" ]; then echo "boundary-scan: clean"; exit 0; fi
printf '%s\n' "$OUT" | cut -c1-160
echo "boundary-scan: $(printf '%s\n' "$OUT" | wc -l) hit(s) - classify each (references/boundary.md)"
exit 1
