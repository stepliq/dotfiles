#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
# shellcheck source=lib/github-bin.sh
source "${ROOT}/lib/github-bin.sh"
dotfiles_skip_apps

DEST="$(dotfiles_dest_bin)"
VERSION="${XXH_VERSION:-0.8.14}"
dotfiles_have_cmd xxh && { dotfiles_log "already installed ($(command -v xxh))"; exit 0; }

if dotfiles_have_cmd pipx; then
  dotfiles_log "installing via pipx"
  pipx install xxh-xxh
  dotfiles_have_cmd xxh && { dotfiles_log "installed via pipx ($(command -v xxh))"; exit 0; }
fi

if dotfiles_have_cmd brew; then
  dotfiles_log "installing via brew"
  brew install xxh
  dotfiles_have_cmd xxh && { dotfiles_log "installed via brew ($(command -v xxh))"; exit 0; }
fi

if [[ "$(uname -s)" == Linux && "$(uname -m)" == x86_64 ]]; then
  dotfiles_install_from_url \
    "https://github.com/xxh/xxh/releases/download/${VERSION}/xxh-portable-musl-alpine-Linux-x86_64.tar.gz" \
    xxh "${DEST}"
  exit 0
fi

dotfiles_warn "no supported install method (need pipx, brew, or Linux x86_64)"
