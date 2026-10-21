#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
# shellcheck source=lib/github-bin.sh
source "${ROOT}/lib/github-bin.sh"
dotfiles_skip_apps

DEST="$(dotfiles_dest_bin)"
dotfiles_have_cmd sshx && { dotfiles_log "already installed ($(command -v sshx))"; exit 0; }

arch_raw="$(uname -m)"
os="$(uname -s)"
case "${os}" in
  Linux*) suffix=-unknown-linux-musl ;;
  Darwin*) suffix=-apple-darwin ;;
  FreeBSD*) suffix=-unknown-freebsd ;;
  *) dotfiles_warn "unsupported OS: ${os}"; exit 0 ;;
esac

case "${arch_raw}" in
  aarch64|aarch64_be|arm64|armv8b|armv8l) arch=aarch64 ;;
  x86_64|x64|amd64) arch=x86_64 ;;
  armv6l) arch=arm; suffix="${suffix}eabihf" ;;
  armv7l) arch=armv7; suffix="${suffix}eabihf" ;;
  *) dotfiles_warn "unsupported arch: ${arch_raw}"; exit 0 ;;
esac

dotfiles_install_from_url \
  "https://s3.amazonaws.com/sshx/sshx-${arch}${suffix}.tar.gz" \
  sshx "${DEST}"
