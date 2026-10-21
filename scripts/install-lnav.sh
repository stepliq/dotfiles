#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps

VERSION="${LNAV_VERSION:-0.14.1}"
DEST="$(dotfiles_dest_bin)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles-lnav"
mkdir -p "${DATA}"

if dotfiles_have_cmd lnav; then
  dotfiles_log "already installed ($(command -v lnav))"
  exit 0
fi

case "$(uname -s):$(uname -m)" in
  Linux:x86_64) suffix=linux-musl-x86_64 ;;
  Linux:aarch64|Linux:arm64) suffix=linux-musl-arm64 ;;
  Darwin:arm64) suffix=aarch64-macos ;;
  *)
    dotfiles_warn "unsupported platform: $(uname -s)/$(uname -m)"
    exit 0
    ;;
esac

name="lnav-${VERSION}-${suffix}"
url="https://github.com/tstack/lnav/releases/download/v${VERSION}/${name}.zip"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

dotfiles_log "downloading ${url}"
curl -fsSL "${url}" -o "${tmp}/lnav.zip"
rm -rf "${DATA}"/lnav-*
unzip -oq "${tmp}/lnav.zip" -d "${DATA}"

shopt -s nullglob
dirs=( "${DATA}"/lnav-* )
shopt -u nullglob
((${#dirs[@]} >= 1)) || dotfiles_die "expected lnav-* directory after unzip"

bin=""
for dir in "${dirs[@]}"; do
  if [[ -x "${dir}/lnav" ]]; then
    bin="${dir}/lnav"
    break
  fi
done
[[ -n "${bin}" ]] || dotfiles_die "binary missing after unzip"

ln -sfn "${bin}" "${DEST}/lnav"
dotfiles_log "installed ${DEST}/lnav -> ${bin}"
