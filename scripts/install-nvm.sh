#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
V="${NVM_VERSION:-v0.40.1}"
[[ -s $NVM_DIR/nvm.sh ]] || curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$V/install.sh" | bash
# shellcheck disable=SC1090
source "$NVM_DIR/nvm.sh"
if dotfiles_have_cmd node; then
  dotfiles_log "node already present ($(node -v))"
  exit 0
fi
nvm install node
