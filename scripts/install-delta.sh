#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0

VERSION="${DELTA_VERSION:-0.19.2}"
DEST="${HOME}/.local/bin"
mkdir -p "${DEST}"

if [[ -x "${DEST}/delta" ]]; then
  echo "delta: already installed ($("${DEST}/delta" --version 2>/dev/null | head -n1 || true))"
  exit 0
fi

arch="$(uname -m)"
os="$(uname -s)"
suffix=

if [[ "${os}" == "Linux" ]]; then
  case "${arch}" in
    x86_64) suffix=x86_64-unknown-linux-gnu ;;
    aarch64) suffix=aarch64-unknown-linux-gnu ;;
    *) echo "delta: unsupported Linux arch: ${arch}" >&2; exit 1 ;;
  esac
elif [[ "${os}" == "Darwin" ]]; then
  case "${arch}" in
    x86_64) suffix=x86_64-apple-darwin ;;
    arm64) suffix=aarch64-apple-darwin ;;
    *) echo "delta: unsupported Darwin arch: ${arch}" >&2; exit 1 ;;
  esac
else
  echo "delta: unsupported OS: ${os}" >&2
  exit 1
fi

name="delta-${VERSION}-${suffix}"
url="https://github.com/dandavison/delta/releases/download/${VERSION}/${name}.tar.gz"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

echo "delta: downloading ${url}"
curl -fsSL "${url}" | tar -xzf - -C "${tmp}"

bin=""
if [[ -f "${tmp}/${name}/delta" ]]; then
  bin="${tmp}/${name}/delta"
else
  bin="$(find "${tmp}" -maxdepth 3 -name delta -type f 2>/dev/null | head -n1 || true)"
fi
[[ -n "${bin}" && -f "${bin}" ]] || { echo "delta: could not find delta binary in archive" >&2; exit 1; }
chmod +x "${bin}"

install -m0755 "${bin}" "${DEST}/delta"
echo "delta: installed ${DEST}/delta ($("${DEST}/delta" --version | head -n1))"
