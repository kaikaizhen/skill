#!/usr/bin/env bash
# One-off helper: copy the NAS credential entries from `pass` into `gopass`.
#
# Run it ONLY when the user asked, on a machine that has BOTH tools and the GPG
# secret key for the pass store. Secrets stream pass -> gopass through a pipe:
# never printed, never logged, never written to a file. The source is never changed.
#
# Usage: migrate-pass-to-gopass.sh [--force]
set -euo pipefail

FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1
ENTRIES=("nas/ssh/config" "nas/ssh/key")

command -v pass   >/dev/null || { echo "pass not found" >&2; exit 2; }
command -v gopass >/dev/null || { echo "gopass not found" >&2; exit 2; }
pass ls   >/dev/null 2>&1 || { echo "pass store is not initialised" >&2; exit 2; }
gopass ls >/dev/null 2>&1 || { echo "gopass store is not initialised" >&2; exit 2; }

for e in "${ENTRIES[@]}"; do
  # existence is checked by listing, never by showing
  pass ls "$e" >/dev/null 2>&1 || { echo "source entry missing in pass: $e" >&2; exit 3; }
  if gopass ls "$e" >/dev/null 2>&1 && [ "$FORCE" -ne 1 ]; then
    echo "target already exists in gopass: $e (use --force to overwrite)" >&2
    exit 4
  fi
done

for e in "${ENTRIES[@]}"; do
  # stdout of `pass show` goes only into gopass's stdin
  pass show "$e" | gopass insert -f -m "$e" >/dev/null
  echo "migrated: $e"
done

echo "--- verify (listing only; never 'gopass show nas/ssh/key') ---"
gopass ls nas/ssh
