#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
V="${NVM_VERSION:-v0.40.1}"
[[ -s $NVM_DIR/nvm.sh ]] || curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$V/install.sh" | bash
# shellcheck disable=SC1090
source "$NVM_DIR/nvm.sh"
if command -v node >/dev/null 2>&1; then
  echo "nvm: node already present ($(node -v))"
  exit 0
fi
nvm install node
