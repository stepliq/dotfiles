#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0
[[ "$(uname -s)" == Linux ]] || exit 0
[[ -f /etc/redhat-release ]] || exit 0
d="${HOME}/.local/bin"
mkdir -p "$d"
command -v unp >/dev/null && exit 0
t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
v=()
[[ -n "${UNP_DEB_VER:-}" ]] && v+=("$UNP_DEB_VER")
v+=(2.0 2.0-1 2.0-2 2.0.0-3)
ok=
for ver in "${v[@]}"; do
  if curl -fsSL "https://deb.debian.org/debian/pool/main/u/unp/unp_${ver}_all.deb" -o"$t/u.deb" 2>/dev/null && [[ -s "$t/u.deb" ]]; then
    ok=1
    break
  fi
  rm -f "$t/u.deb"
done
[[ -n "$ok" ]] || exit 1
data=$(ar t "$t/u.deb" | grep -E '^data\.tar' | head -1)
[[ -n "$data" ]] || exit 1
(cd "$t" && ar x u.deb "$data" && tar -xf "$data" ./usr/bin/unp)
install -m0755 "$t/usr/bin/unp" "$d/unp"
trap - EXIT
rm -rf "$t"
