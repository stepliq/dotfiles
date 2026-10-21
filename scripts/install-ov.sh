#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0

VERSION="${OV_VERSION:-0.55.0}"
DEST="${HOME}/.local/bin"
mkdir -p "${DEST}"

if command -v ov >/dev/null 2>&1; then
  echo "ov: already installed ($(ov --version 2>/dev/null | head -n1 || true))"
  exit 0
fi

arch="$(uname -m)"
os="$(uname -s)"
suffix=

if [[ "${os}" == "Linux" ]]; then
  case "${arch}" in
    x86_64) suffix=linux_amd64 ;;
    aarch64) suffix=linux_arm64 ;;
    armv7l|armv6l) suffix=linux_arm ;;
    i386|i686) suffix=linux_386 ;;
    *) echo "ov: unsupported Linux arch: ${arch}" >&2; exit 0 ;;
  esac
elif [[ "${os}" == "Darwin" ]]; then
  case "${arch}" in
    x86_64) suffix=darwin_amd64 ;;
    arm64) suffix=darwin_arm64 ;;
    *) echo "ov: unsupported Darwin arch: ${arch}" >&2; exit 0 ;;
  esac
else
  echo "ov: unsupported OS: ${os}" >&2
  exit 0
fi

url="https://github.com/noborus/ov/releases/download/v${VERSION}/ov_${VERSION}_${suffix}.zip"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

echo "ov: downloading ${url}"
curl -fsSL "${url}" -o "${tmp}/ov.zip"
unzip -oq "${tmp}/ov.zip" -d "${tmp}"

bin="${tmp}/ov"
[[ -f "${bin}" ]] || bin="$(find "${tmp}" -maxdepth 2 -type f -name ov | head -n1 || true)"
[[ -n "${bin}" && -f "${bin}" ]] || { echo "ov: could not find ov binary in archive" >&2; exit 1; }
chmod +x "${bin}"
install -m0755 "${bin}" "${DEST}/ov"
echo "ov: installed ${DEST}/ov ($(${DEST}/ov --version | head -n1))"
