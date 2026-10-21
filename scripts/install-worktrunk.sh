#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0
export PATH="$HOME/.cargo/bin:$PATH"
command -v cargo >/dev/null 2>&1 || exit 0
if ! command -v wt >/dev/null 2>&1 && [[ ! -x "$HOME/.cargo/bin/wt" ]]; then
  cargo install worktrunk --locked
fi
WT="$(command -v wt 2>/dev/null || echo "$HOME/.cargo/bin/wt")"
[[ -x "$WT" ]] || exit 1
"$WT" config shell install --yes
