#!/usr/bin/env bash
# Fail if a git-agecrypt path is plaintext.
# Check the git blob, not the working tree: smudge decrypts checked-out files.
# Usage: check-agecrypt.sh [HEAD|index]
set -euo pipefail

mode=${1:-HEAD}
root=$(git rev-parse --show-toplevel)
cd "$root"

case "$mode" in
  HEAD) spec() { printf 'HEAD:%s' "$1"; } ;;
  index) spec() { printf ':%s' "$1"; } ;;
  *)
    echo "usage: $0 [HEAD|index]" >&2
    exit 2
    ;;
esac

attrs=$(mktemp)
trap 'rm -f "$attrs"' EXIT

if ! git cat-file -e "$(spec .gitattributes)" 2>/dev/null; then
  echo "missing .gitattributes from $mode" >&2
  exit 1
fi
git cat-file -p "$(spec .gitattributes)" >"$attrs"

fail=0
found=0

while read -r path _; do
  [[ -z "$path" || "$path" == \#* ]] && continue
  found=1

  object=$(spec "$path")
  if ! git cat-file -e "$object" 2>/dev/null; then
    echo "missing from $mode: $path" >&2
    fail=1
    continue
  fi

  blob=$(mktemp)
  git cat-file -p "$object" >"$blob"
  header=$(head -n 1 "$blob" | tr -d '\r')
  rm -f "$blob"

  if [[ "$header" != "age-encryption.org/v1" ]]; then
    echo "not encrypted: $path" >&2
    fail=1
  fi
done < <(awk '/filter=git-agecrypt/ { print $1 }' "$attrs")

if [[ "$found" -eq 0 ]]; then
  echo "no git-agecrypt paths in .gitattributes" >&2
  exit 1
fi

exit "$fail"
