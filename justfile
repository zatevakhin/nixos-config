set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

ci: check-secrets fmt-check

pre-commit: (check-secrets "index") fmt-check-staged

check-secrets mode="HEAD":
    #!/usr/bin/env bash
    set -euo pipefail
    mode='{{mode}}'
    root=$(git rev-parse --show-toplevel)
    cd "$root"

    case "$mode" in
      HEAD) spec() { printf 'HEAD:%s' "$1"; } ;;
      index) spec() { printf ':%s' "$1"; } ;;
      *)
        echo "usage: just check-secrets [HEAD|index]" >&2
        exit 2
        ;;
    esac

    list_paths() {
      if [[ "$mode" == HEAD ]]; then
        git ls-tree -r --name-only HEAD
      else
        git ls-files
      fi
    }

    fail=0
    attrs=$(mktemp)
    blob=$(mktemp)
    trap 'rm -f "$attrs" "$blob"' EXIT

    if ! git cat-file -e "$(spec .gitattributes)" 2>/dev/null; then
      echo "missing .gitattributes from $mode" >&2
      exit 1
    fi
    git cat-file -p "$(spec .gitattributes)" >"$attrs"

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
      git cat-file -p "$object" >"$blob"
      header=$(head -n 1 "$blob" | tr -d '\r')
      if [[ "$header" != "age-encryption.org/v1" ]]; then
        echo "agecrypt path is not encrypted: $path" >&2
        fail=1
      fi
    done < <(awk '/filter=git-agecrypt/ { print $1 }' "$attrs")

    if [[ "$found" -eq 0 ]]; then
      echo "no git-agecrypt paths in .gitattributes" >&2
      exit 1
    fi

    pem_begin='-----BEGIN '
    pem_end='PRIVATE KEY-----'
    age_secret=$(printf '%s%s' 'AGE-SECRET-' 'KEY-1')
    secret_re="${pem_begin}(OPENSSH |RSA |EC |DSA )?${pem_end}|${age_secret}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|^[ \t]*PrivateKey[ \t]*=[ \t]*[A-Za-z0-9+/]{43}="

    while read -r path; do
      [[ -z "$path" ]] && continue
      case "$path" in
        extra-files/* | */luks.keyfile | luks.keyfile)
          echo "refusing tracked secret path: $path" >&2
          fail=1
          continue
          ;;
      esac

      git cat-file -p "$(spec "$path")" >"$blob"
      if [[ "$(head -n 1 "$blob" | tr -d '\r')" == "age-encryption.org/v1" ]]; then
        continue
      fi
      if grep -a -E -q -e "$secret_re" -- "$blob"; then
        echo "plaintext secret material: $path" >&2
        fail=1
      fi
      if [[ "$path" == secrets/*.yaml || "$path" == secrets/*/*.yaml ]]; then
        if ! grep -q 'ENC\[AES256_GCM' "$blob" || ! grep -q '^sops:' "$blob"; then
          echo "secrets file is not sops-encrypted: $path" >&2
          fail=1
        fi
      fi
    done < <(list_paths)

    exit "$fail"

fmt-check:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v alejandra >/dev/null 2>&1; then
      alejandra --check .
    elif command -v nix >/dev/null 2>&1; then
      nix --quiet fmt -- --check .
    else
      echo "alejandra not found; enter the flake devShell or install nix" >&2
      exit 1
    fi

fmt-check-staged:
    #!/usr/bin/env bash
    set -euo pipefail
    mapfile -t files < <(git diff --cached --name-only --diff-filter=ACMR -- '*.nix')
    ((${#files[@]})) || exit 0
    if command -v alejandra >/dev/null 2>&1; then
      alejandra --check "${files[@]}"
    elif command -v nix >/dev/null 2>&1; then
      nix --quiet fmt -- --check "${files[@]}"
    else
      echo "alejandra not found; enter the flake devShell or install nix" >&2
      exit 1
    fi
