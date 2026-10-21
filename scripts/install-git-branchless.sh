#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps
if dotfiles_have_cmd git-branchless || git branchless --help >/dev/null 2>&1; then
  dotfiles_log "already installed"
  exit 0
fi

export PATH="${HOME}/.cargo/bin:${PATH}"
if ! dotfiles_have_cmd cargo; then
  dotfiles_warn "cargo not found; skip cargo fallback"
  exit 0
fi

dotfiles_log "installing via cargo"
cargo install --locked git-branchless
dotfiles_log "installed ($(command -v git-branchless || echo "${HOME}/.cargo/bin/git-branchless"))"
dotfiles_log "run 'git branchless init' inside each repo you want to use"
