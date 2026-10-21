#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0

DEST="${HOME}/.local/bin"
mkdir -p "${DEST}"

if command -v sshx >/dev/null 2>&1; then
  echo "sshx: already installed ($(command -v sshx))"
  exit 0
fi

arch_raw="$(uname -m)"
os="$(uname -s)"
suffix=
arch=

case "${os}" in
  Linux*) suffix="-unknown-linux-musl" ;;
  Darwin*) suffix="-apple-darwin" ;;
  FreeBSD*) suffix="-unknown-freebsd" ;;
  *)
    echo "sshx: unsupported OS: ${os}" >&2
    exit 0
    ;;
esac

case "${arch_raw}" in
  aarch64|aarch64_be|arm64|armv8b|armv8l) arch="aarch64" ;;
  x86_64|x64|amd64) arch="x86_64" ;;
  armv6l)
    arch="arm"
    suffix="${suffix}eabihf"
    ;;
  armv7l)
    arch="armv7"
    suffix="${suffix}eabihf"
    ;;
  *)
    echo "sshx: unsupported arch: ${arch_raw}" >&2
    exit 0
    ;;
esac

url="https://s3.amazonaws.com/sshx/sshx-${arch}${suffix}.tar.gz"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

echo "sshx: downloading ${url}"
curl -fsSL "${url}" -o "${tmp}/sshx.tar.gz"
tar -xzf "${tmp}/sshx.tar.gz" -C "${tmp}"

bin="${tmp}/sshx"
[[ -f "${bin}" ]] || bin="$(find "${tmp}" -maxdepth 2 -type f -name sshx | head -n1 || true)"
[[ -n "${bin}" && -f "${bin}" ]] || { echo "sshx: could not find sshx binary in archive" >&2; exit 1; }
chmod +x "${bin}"
install -m0755 "${bin}" "${DEST}/sshx"
echo "sshx: installed ${DEST}/sshx"
