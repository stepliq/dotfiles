#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps

[[ -t 0 ]] || { dotfiles_log "non-interactive — skip"; exit 0; }

zsh_path="$(command -v zsh)"
[[ -n "$zsh_path" && -x "$zsh_path" ]] || dotfiles_die "zsh not in PATH"

current_shell="$(readlink -f "${SHELL}" 2>/dev/null || echo "$SHELL")"
target_shell="$(readlink -f "$zsh_path")"
[[ $current_shell == "$target_shell" ]] && exit 0

grep -qxF "$zsh_path" /etc/shells 2>/dev/null || dotfiles_warn "$zsh_path not in /etc/shells"
exec chsh -s "$zsh_path"
