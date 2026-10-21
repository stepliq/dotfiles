#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps

[[ "$(uname -s)" == Linux ]] || exit 0
[[ -f /etc/redhat-release ]] || exit 0

dest="$(dotfiles_dest_bin)"
dotfiles_have_cmd unp && exit 0

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

versions=()
[[ -n "${UNP_DEB_VER:-}" ]] && versions+=("$UNP_DEB_VER")
versions+=(2.0 2.0-1 2.0-2 2.0.0-3)

deb=""
for version in "${versions[@]}"; do
  candidate="$tmp/unp.deb"
  if curl -fsSL "https://deb.debian.org/debian/pool/main/u/unp/unp_${version}_all.deb" -o"$candidate" 2>/dev/null && [[ -s "$candidate" ]]; then
    deb="$candidate"
    break
  fi
  rm -f "$candidate"
done
[[ -n "$deb" ]] || exit 1

data_archive="$(ar t "$deb" | grep -E '^data\.tar' | head -1)"
[[ -n "$data_archive" ]] || exit 1

(
  cd "$tmp"
  ar x unp.deb "$data_archive"
  tar -xf "$data_archive" ./usr/bin/unp
)
install -m0755 "$tmp/usr/bin/unp" "$dest/unp"
