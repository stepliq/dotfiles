#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[[ -s "$NVM_DIR/nvm.sh" ]] || exit 0
# shellcheck disable=SC1090
source "$NVM_DIR/nvm.sh"
nvm use default >/dev/null 2>&1 || nvm install node
dotfiles_have_cmd npm || exit 0
dotfiles_have_cmd branchlet || npm install -g branchlet
