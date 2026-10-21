#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps
dotfiles_have_cmd cargo || exit 0
dotfiles_have_cmd agg && exit 0
CARGO_INSTALL_ROOT="${HOME}/.local" cargo install --git https://github.com/asciinema/agg
