#!/usr/bin/env bash
# shellcheck shell=bash

dotfiles_dest_bin() {
  local dest="${HOME}/.local/bin"
  mkdir -p "${dest}"
  printf '%s\n' "${dest}"
}

dotfiles_have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

dotfiles_cargo_install() {
  local crate="$1"
  export PATH="${HOME}/.cargo/bin:${PATH}"
  command -v cargo >/dev/null 2>&1 || return 1
  cargo install --locked "${crate}"
}

dotfiles_install_from_url() {
  local url="$1" bin_name="$2" dest="${3:-$(dotfiles_dest_bin)}"
  local tmp archive extracted
  tmp="$(mktemp -d)"
  # shellcheck disable=SC2064
  trap "rm -rf '${tmp}'" RETURN

  mkdir -p "${dest}"
  archive="${tmp}/asset"
  echo "${bin_name}: downloading ${url}"
  curl -fsSL "${url}" -o "${archive}"

  case "${url}" in
    *.tar.gz|*.tgz) tar -xzf "${archive}" -C "${tmp}" ;;
    *.tar.xz) tar -xJf "${archive}" -C "${tmp}" ;;
    *.zip) unzip -oq "${archive}" -d "${tmp}" ;;
    *)
      chmod +x "${archive}"
      install -m0755 "${archive}" "${dest}/${bin_name}"
      return 0
      ;;
  esac

  extracted="$(find "${tmp}" -type f -name "${bin_name}" | head -n1 || true)"
  [[ -n "${extracted}" && -f "${extracted}" ]] || {
    echo "${bin_name}: could not find binary in archive" >&2
    return 1
  }
  chmod +x "${extracted}"
  install -m0755 "${extracted}" "${dest}/${bin_name}"
  echo "${bin_name}: installed ${dest}/${bin_name}"
}

dotfiles_ensure_symlink() {
  local target="$1" link_name="$2" dest
  dest="$(dotfiles_dest_bin)"
  command -v "${link_name}" >/dev/null 2>&1 && return 0
  if command -v "${target}" >/dev/null 2>&1; then
    ln -sfn "$(command -v "${target}")" "${dest}/${link_name}"
    echo "compat: ${dest}/${link_name} -> ${target}"
  fi
}
