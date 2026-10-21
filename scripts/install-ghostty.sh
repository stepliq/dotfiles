#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps
dotfiles_have_cmd ghostty && exit 0

if dotfiles_have_cmd dnf; then
  sudo dnf -y copr enable scottames/ghostty
  sudo dnf install -y ghostty
elif dotfiles_have_cmd apt-get; then
  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"; then
    dotfiles_warn "ubuntu installer failed (continuing)"
    exit 0
  fi
else
  dotfiles_die "unsupported OS"
fi
