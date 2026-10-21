#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0
v="${LAZYDOCKER_VERSION:-0.25.2}"
d="${HOME}/.local/bin"
mkdir -p "$d"
command -v lazydocker >/dev/null && exit 0
os=$(uname -s)
a=$(uname -m)
if [[ "$os" == Linux ]]; then
  case "$a" in
    x86_64) s=Linux_x86_64 ;;
    aarch64) s=Linux_arm64 ;;
    armv7l) s=Linux_armv7 ;;
    *) exit 0 ;;
  esac
elif [[ "$os" == Darwin ]]; then
  case "$a" in
    x86_64) s=Darwin_x86_64 ;;
    arm64) s=Darwin_arm64 ;;
    *) exit 0 ;;
  esac
else
  exit 0
fi
t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
n="lazydocker_${v}_${s}.tar.gz"
curl -fsSL "https://github.com/jesseduffield/lazydocker/releases/download/v${v}/${n}" | tar -xzf - -C "$t"
b=$(find "$t" -type f -name lazydocker | head -1)
[[ -n "$b" ]] || exit 1
install -m0755 "$b" "$d/lazydocker"
trap - EXIT
rm -rf "$t"
