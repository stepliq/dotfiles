#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps

export PATH="$HOME/.cargo/bin:$PATH"
dotfiles_have_cmd cargo || exit 0

if ! dotfiles_have_cmd wt && [[ ! -x "$HOME/.cargo/bin/wt" ]]; then
  cargo install worktrunk --locked
fi

wt_bin="$(command -v wt 2>/dev/null || echo "$HOME/.cargo/bin/wt")"
[[ -x "$wt_bin" ]] || exit 1
"$wt_bin" config shell install --yes
