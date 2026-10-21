#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0

if [[ -x "${HOME}/.go/bin/go" ]] || command -v go >/dev/null 2>&1; then
  echo "go: already installed ($(command -v go 2>/dev/null || echo "${HOME}/.go/bin/go"))"
  exit 0
fi

ver="${GO_VERSION:-1.24.2}"
arch="$(uname -m)"
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "${arch}" in
  x86_64|amd64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  *)
    echo "install-go: unsupported arch ${arch}" >&2
    exit 1
    ;;
esac

url="https://go.dev/dl/go${ver}.${os}-${arch}.tar.gz"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

echo "go: downloading ${url}"
curl -fsSL --connect-timeout 10 --max-time 300 "${url}" -o "${tmp}/go.tgz"
tar -xzf "${tmp}/go.tgz" -C "${tmp}"
rm -rf "${HOME}/.go"
mv "${tmp}/go" "${HOME}/.go"
mkdir -p "${HOME}/go"
echo "go: installed ${HOME}/.go (version ${ver})"
