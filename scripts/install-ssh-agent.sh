#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
# shellcheck source=lib/ssh-agent.sh
source "${ROOT}/lib/ssh-agent.sh"

runtime_dir="$(dotfiles_runtime_dir)"
env_dir="${XDG_CONFIG_HOME:-$HOME/.config}/environment.d"
mkdir -p "$env_dir"
dotfiles_have_cmd systemctl || exit 0

if systemctl --user cat ssh-agent.socket &>/dev/null; then
  systemctl --user enable --now ssh-agent.socket
elif systemctl --user cat ssh-agent.service &>/dev/null; then
  systemctl --user enable --now ssh-agent.service
else
  dotfiles_warn "no user unit"
  exit 0
fi

listen="$(systemctl --user cat ssh-agent.socket 2>/dev/null | awk -F= '/^ListenStream=/ {print $2; exit}')" || true
case ${listen:-} in
  %t/*) sock="$runtime_dir/${listen#%t/}" ;;
  /*) sock="$listen" ;;
  *) sock= ;;
esac

[[ -n ${sock:-} && -S $sock ]] || sock="$(dotfiles_find_ssh_agent_socket)" || sock=
[[ -n ${sock:-} ]] || { dotfiles_warn "no socket path"; exit 0; }

rel="${sock#"$runtime_dir/"}"
if [[ $rel == "$sock" ]]; then
  printf 'SSH_AUTH_SOCK=%s\n' "$sock" >"$env_dir/ssh-agent.conf"
  dotfiles_log "SSH_AUTH_SOCK=$sock"
else
  printf 'SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/%s\n' "$rel" >"$env_dir/ssh-agent.conf"
  dotfiles_log "SSH_AUTH_SOCK=\$XDG_RUNTIME_DIR/$rel"
fi
systemctl --user set-environment "SSH_AUTH_SOCK=$sock" 2>/dev/null || true
