#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps

export PATH="$HOME/.cargo/bin:$PATH"
dotfiles_have_cmd cargo || exit 0

if ! dotfiles_have_cmd kache && [[ ! -x "$HOME/.cargo/bin/kache" ]]; then
  cargo install kache --locked
fi

kache_bin="$(command -v kache 2>/dev/null || echo "$HOME/.cargo/bin/kache")"
[[ -x "$kache_bin" ]] || exit 1
"$kache_bin" init -y --no-shell
"$kache_bin" init --shims
