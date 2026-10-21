#!/usr/bin/env bash

: "${DOTFILES_SCRIPT:=${0##*/}}"
DOTFILES_SCRIPT="${DOTFILES_SCRIPT%.sh}"

dotfiles_log() {
  printf '%s: %s\n' "$DOTFILES_SCRIPT" "$*"
}

dotfiles_warn() {
  printf '%s: %s\n' "$DOTFILES_SCRIPT" "$*" >&2
}

dotfiles_die() {
  dotfiles_warn "$*"
  exit 1
}

dotfiles_skip_apps() {
  [[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0
}

dotfiles_have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

dotfiles_dest_bin() {
  local dest="${HOME}/.local/bin"
  mkdir -p "${dest}"
  printf '%s\n' "${dest}"
}

dotfiles_python() {
  local lib
  lib="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PYTHONPATH="${lib}${PYTHONPATH:+:$PYTHONPATH}" python3 "$@"
}
