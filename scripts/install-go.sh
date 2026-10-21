#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps
if [[ -x "${HOME}/.go/bin/go" ]] || dotfiles_have_cmd go; then
  dotfiles_log "already installed ($(command -v go 2>/dev/null || echo "${HOME}/.go/bin/go"))"
  exit 0
fi

ver="${GO_VERSION:-1.24.2}"
arch="$(uname -m)"
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "${arch}" in
  x86_64|amd64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  *) dotfiles_die "unsupported arch ${arch}" ;;
esac

url="https://go.dev/dl/go${ver}.${os}-${arch}.tar.gz"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

dotfiles_log "downloading ${url}"
curl -fsSL --connect-timeout 10 --max-time 300 "${url}" -o "${tmp}/go.tgz"
tar -xzf "${tmp}/go.tgz" -C "${tmp}"
rm -rf "${HOME}/.go"
mv "${tmp}/go" "${HOME}/.go"
mkdir -p "${HOME}/go"
dotfiles_log "installed ${HOME}/.go (version ${ver})"
