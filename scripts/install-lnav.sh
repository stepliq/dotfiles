#!/usr/bin/env bash
set -euo pipefail

VERSION="${LNAV_VERSION:-0.14.1}"
DEST="${HOME}/.local/bin"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles-lnav"
mkdir -p "${DEST}" "${DATA}"

if command -v lnav >/dev/null 2>&1; then
  echo "lnav: already installed ($(command -v lnav))"
  exit 0
fi

arch="$(uname -m)"
os="$(uname -s)"
suffix=

if [[ "${os}" == "Linux" ]]; then
  case "${arch}" in
    x86_64) suffix=linux-musl-x86_64 ;;
    aarch64|arm64) suffix=linux-musl-arm64 ;;
    *) echo "lnav: unsupported Linux arch: ${arch}" >&2; exit 0 ;;
  esac
elif [[ "${os}" == "Darwin" ]]; then
  case "${arch}" in
    arm64) suffix=aarch64-macos ;;
    *) echo "lnav: unsupported Darwin arch: ${arch}" >&2; exit 0 ;;
  esac
else
  echo "lnav: unsupported OS: ${os}" >&2
  exit 0
fi

name="lnav-${VERSION}-${suffix}"
url="https://github.com/tstack/lnav/releases/download/v${VERSION}/${name}.zip"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

echo "lnav: downloading ${url}"
curl -fsSL "${url}" -o "${tmp}/lnav.zip"
rm -rf "${DATA}"/lnav-*
unzip -oq "${tmp}/lnav.zip" -d "${DATA}"

shopt -s nullglob
dirs=( "${DATA}"/lnav-* )
shopt -u nullglob
((${#dirs[@]} >= 1)) || { echo "lnav: expected lnav-* directory after unzip" >&2; exit 1; }

bin=""
for d in "${dirs[@]}"; do
  if [[ -x "${d}/lnav" ]]; then
    bin="${d}/lnav"
    break
  fi
done
[[ -n "${bin}" ]] || { echo "lnav: binary missing after unzip" >&2; exit 1; }

ln -sfn "${bin}" "${DEST}/lnav"
echo "lnav: installed ${DEST}/lnav -> ${bin}"
