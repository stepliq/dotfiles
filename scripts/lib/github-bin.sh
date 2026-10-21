#!/usr/bin/env bash

_DOTFILES_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${_DOTFILES_LIB_DIR}/common.sh"

dotfiles_cargo_install() {
  local crate="$1"
  export PATH="${HOME}/.cargo/bin:${PATH}"
  dotfiles_have_cmd cargo || return 1
  cargo install --locked "${crate}"
}

dotfiles_install_from_url() {
  local url="$1" bin_name="$2" dest="${3:-$(dotfiles_dest_bin)}"
  DOTFILES_SCRIPT="${bin_name}" dotfiles_python "${_DOTFILES_LIB_DIR}/fetch_bin.py" "${url}" "${bin_name}" "${dest}"
}

dotfiles_ensure_symlink() {
  local target="$1" link_name="$2" dest
  dest="$(dotfiles_dest_bin)"
  dotfiles_have_cmd "${link_name}" && return 0
  if dotfiles_have_cmd "${target}"; then
    ln -sfn "$(command -v "${target}")" "${dest}/${link_name}"
    dotfiles_log "compat: ${dest}/${link_name} -> ${target}"
  fi
}
