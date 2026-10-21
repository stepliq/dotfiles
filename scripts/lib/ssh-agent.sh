#!/usr/bin/env bash

dotfiles_runtime_dir() {
  printf '%s\n' "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
}

dotfiles_find_ssh_agent_socket() {
  local runtime sock

  if [[ -n ${SSH_AUTH_SOCK:-} && -S $SSH_AUTH_SOCK ]]; then
    printf '%s\n' "$SSH_AUTH_SOCK"
    return 0
  fi

  runtime="$(dotfiles_runtime_dir)"
  for sock in "$runtime/ssh-agent.socket" "$runtime/openssh_agent"; do
    if [[ -S $sock ]]; then
      printf '%s\n' "$sock"
      return 0
    fi
  done

  return 1
}
