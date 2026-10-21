#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0
export PATH="$HOME/.cargo/bin:$PATH"
command -v cargo >/dev/null 2>&1 || exit 0
if ! command -v kache >/dev/null 2>&1 && [[ ! -x "$HOME/.cargo/bin/kache" ]]; then
  cargo install kache --locked
fi
KACHE="$(command -v kache 2>/dev/null || echo "$HOME/.cargo/bin/kache")"
[[ -x "$KACHE" ]] || exit 1
"$KACHE" init -y --no-shell
"$KACHE" init --shims
