#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[[ -s "$NVM_DIR/nvm.sh" ]] || exit 0
# shellcheck disable=SC1090
source "$NVM_DIR/nvm.sh"
nvm use default >/dev/null 2>&1 || nvm install node
command -v npm >/dev/null 2>&1 || exit 0
if ! command -v branchlet >/dev/null 2>&1; then
  npm install -g branchlet
fi
