#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/github-bin.sh
source "${ROOT}/lib/github-bin.sh"

DEST="$(dotfiles_dest_bin)"
arch="$(uname -m)"
os="$(uname -s)"

install_just() {
  local ver="${JUST_VERSION:-1.59.0}" suffix url
  case "${os}:${arch}" in
    Linux:x86_64) suffix=x86_64-unknown-linux-musl ;;
    Linux:aarch64) suffix=aarch64-unknown-linux-musl ;;
    Darwin:x86_64) suffix=x86_64-apple-darwin ;;
    Darwin:arm64) suffix=aarch64-apple-darwin ;;
    *) return 1 ;;
  esac
  url="https://github.com/casey/just/releases/download/${ver}/just-${ver}-${suffix}.tar.gz"
  dotfiles_install_from_url "${url}" just "${DEST}"
}

install_eza() {
  local ver="${EZA_VERSION:-0.23.5}" suffix url
  case "${os}:${arch}" in
    Linux:x86_64) suffix=x86_64-unknown-linux-musl ;;
    Linux:aarch64) suffix=aarch64-unknown-linux-gnu ;;
    *)
      echo "eza: no release archive for ${os}/${arch}; trying cargo"
      dotfiles_cargo_install eza
      return
      ;;
  esac
  url="https://github.com/eza-community/eza/releases/download/v${ver}/eza_${suffix}.tar.gz"
  dotfiles_install_from_url "${url}" eza "${DEST}"
}

install_lazygit() {
  local ver="${LAZYGIT_VERSION:-0.66.2}" suffix url
  case "${os}:${arch}" in
    Linux:x86_64) suffix=linux_x86_64 ;;
    Linux:aarch64) suffix=linux_arm64 ;;
    Darwin:x86_64) suffix=darwin_x86_64 ;;
    Darwin:arm64) suffix=darwin_arm64 ;;
    *) return 1 ;;
  esac
  url="https://github.com/jesseduffield/lazygit/releases/download/v${ver}/lazygit_${ver}_${suffix}.tar.gz"
  dotfiles_install_from_url "${url}" lazygit "${DEST}"
}

install_procs() {
  local ver="${PROCS_VERSION:-0.14.12}" suffix url
  case "${os}:${arch}" in
    Linux:x86_64) suffix=x86_64-linux ;;
    Linux:aarch64) suffix=aarch64-linux ;;
    Darwin:x86_64) suffix=x86_64-mac ;;
    Darwin:arm64) suffix=aarch64-mac ;;
    *) return 1 ;;
  esac
  url="https://github.com/dalance/procs/releases/download/v${ver}/procs-v${ver}-${suffix}.zip"
  dotfiles_install_from_url "${url}" procs "${DEST}"
}

install_fq() {
  local ver="${FQ_VERSION:-0.18.0}" suffix url
  case "${os}:${arch}" in
    Linux:x86_64) suffix=linux_amd64; url="https://github.com/wader/fq/releases/download/v${ver}/fq_${ver}_${suffix}.tar.gz" ;;
    Linux:aarch64) suffix=linux_arm64; url="https://github.com/wader/fq/releases/download/v${ver}/fq_${ver}_${suffix}.tar.gz" ;;
    Darwin:x86_64) suffix=macos_amd64; url="https://github.com/wader/fq/releases/download/v${ver}/fq_${ver}_${suffix}.zip" ;;
    Darwin:arm64) suffix=macos_arm64; url="https://github.com/wader/fq/releases/download/v${ver}/fq_${ver}_${suffix}.zip" ;;
    *) return 1 ;;
  esac
  dotfiles_install_from_url "${url}" fq "${DEST}"
}

install_fclones() {
  local ver="${FCLONES_VERSION:-0.35.0}" url
  case "${os}:${arch}" in
    Linux:x86_64)
      url="https://github.com/pkolaczk/fclones/releases/download/v${ver}/fclones-${ver}-linux-musl-x86_64.tar.gz"
      ;;
    *)
      echo "fclones: no release archive for ${os}/${arch}; trying cargo"
      dotfiles_cargo_install fclones
      return
      ;;
  esac
  dotfiles_install_from_url "${url}" fclones "${DEST}"
}

install_erdtree() {
  local ver="${ERDTREE_VERSION:-3.1.2}" suffix url
  case "${os}:${arch}" in
    Linux:x86_64) suffix=x86_64-unknown-linux-musl ;;
    Linux:aarch64) suffix=aarch64-unknown-linux-musl ;;
    Darwin:x86_64) suffix=x86_64-apple-darwin ;;
    Darwin:arm64) suffix=aarch64-apple-darwin ;;
    *) return 1 ;;
  esac
  url="https://github.com/solidiquis/erdtree/releases/download/v${ver}/erd-v${ver}-${suffix}.tar.gz"
  dotfiles_install_from_url "${url}" erd "${DEST}"
}

install_fastfetch() {
  local ver="${FASTFETCH_VERSION:-2.70.0}" suffix url
  case "${os}:${arch}" in
    Linux:x86_64) suffix=linux-amd64 ;;
    Linux:aarch64) suffix=linux-aarch64 ;;
    Darwin:*)
      echo "fastfetch: use brew on macOS if missing" >&2
      return 1
      ;;
    *) return 1 ;;
  esac
  url="https://github.com/fastfetch-cli/fastfetch/releases/download/${ver}/fastfetch-${suffix}.tar.gz"
  local tmp archive extracted
  tmp="$(mktemp -d)"
  trap 'rm -rf "${tmp}"' RETURN
  archive="${tmp}/asset.tar.gz"
  echo "fastfetch: downloading ${url}"
  curl -fsSL "${url}" -o "${archive}"
  tar -xzf "${archive}" -C "${tmp}"
  extracted="$(find "${tmp}" -type f -name fastfetch | head -n1 || true)"
  [[ -n "${extracted}" && -f "${extracted}" ]] || {
    echo "fastfetch: could not find binary in archive" >&2
    return 1
  }
  chmod +x "${extracted}"
  install -m0755 "${extracted}" "${DEST}/fastfetch"
  echo "fastfetch: installed ${DEST}/fastfetch"
}

try_install() {
  local cmd="$1" fn="$2"
  if dotfiles_have_cmd "${cmd}"; then
    echo "${cmd}: already installed ($(command -v "${cmd}"))"
    return 0
  fi
  echo "${cmd}: missing — installing fallback"
  if ! "${fn}"; then
    echo "${cmd}: fallback install failed (continuing)" >&2
    return 0
  fi
}

try_install just install_just
try_install eza install_eza
try_install lazygit install_lazygit
try_install procs install_procs
try_install fq install_fq
try_install fclones install_fclones
try_install erd install_erdtree
try_install fastfetch install_fastfetch
