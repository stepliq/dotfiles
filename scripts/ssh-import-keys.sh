#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
# shellcheck source=lib/ssh-agent.sh
source "${ROOT}/lib/ssh-agent.sh"

usage() {
  cat >&2 <<'EOF'
usage: ssh-import-keys.sh [--clear] <path>...

Copy OpenSSH private keys into ~/.ssh and load them into the agent.
Paths may be key files or directories (non-recursive).

  --clear   remove all identities from the agent first (ssh-add -D)
EOF
  exit 1
}

is_private_key() {
  local path=$1 line name=${1##*/}

  [[ -f $path && -r $path ]] || return 1
  case $name in
    *.pub|authorized_keys|known_hosts*|config|*.ppk) return 1 ;;
  esac

  IFS= read -r line <"$path" || return 1
  [[ $line == *"PRIVATE KEY"* ]]
}

copy_key() {
  local src=$1 dest="$HOME/.ssh/${1##*/}"

  cp -f "$src" "$dest"
  chmod 600 "$dest"

  if [[ -f $src.pub ]]; then
    cp -f "$src.pub" "$dest.pub"
    chmod 644 "$dest.pub"
  fi

  dotfiles_log "copy: $dest"
  copied+=("$dest")
}

import_path() {
  local path=$1 file

  if [[ -f $path ]]; then
    if is_private_key "$path"; then
      copy_key "$path"
    else
      dotfiles_warn "skip: $path"
    fi
    return
  fi

  if [[ -d $path ]]; then
    shopt -s nullglob
    for file in "$path"/*; do
      [[ -f $file ]] || continue
      is_private_key "$file" && copy_key "$file"
    done
    shopt -u nullglob
    return
  fi

  dotfiles_die "not found: $path"
}

parse_args() {
  clear_agent=0
  paths=()

  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help) usage ;;
      --clear) clear_agent=1 ;;
      -*) dotfiles_die "unknown option: $1" ;;
      *) paths+=("$1") ;;
    esac
    shift
  done

  [[ ${#paths[@]} -ge 1 ]] || usage
}

parse_args "$@"

SSH_AUTH_SOCK="$(dotfiles_find_ssh_agent_socket)" || dotfiles_die "no agent socket"
export SSH_AUTH_SOCK

if [[ $clear_agent -eq 1 ]]; then
  ssh-add -D 2>/dev/null || true
  dotfiles_log "cleared agent identities"
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

copied=()
for path in "${paths[@]}"; do
  import_path "$path"
done

[[ ${#copied[@]} -eq 0 ]] && exit 0

mapfile -t shuffled < <(printf '%s\n' "${copied[@]}" | shuf)
for key in "${shuffled[@]}"; do
  dotfiles_log "add: $key"
  ssh-add -- "$key"
done
