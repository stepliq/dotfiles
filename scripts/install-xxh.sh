#!/usr/bin/env bash
set -euo pipefail

DEST="${HOME}/.local/bin"
VERSION="${XXH_VERSION:-0.8.14}"
mkdir -p "${DEST}"

if command -v xxh >/dev/null 2>&1; then
  echo "xxh: already installed ($(command -v xxh))"
  exit 0
fi

if command -v pipx >/dev/null 2>&1; then
  echo "xxh: installing via pipx"
  pipx install xxh-xxh
  if command -v xxh >/dev/null 2>&1; then
    echo "xxh: installed via pipx ($(command -v xxh))"
    exit 0
  fi
fi

if command -v brew >/dev/null 2>&1; then
  echo "xxh: installing via brew"
  brew install xxh
  if command -v xxh >/dev/null 2>&1; then
    echo "xxh: installed via brew ($(command -v xxh))"
    exit 0
  fi
fi

if [[ "$(uname -s)" == "Linux" && "$(uname -m)" == "x86_64" ]]; then
  url="https://github.com/xxh/xxh/releases/download/${VERSION}/xxh-portable-musl-alpine-Linux-x86_64.tar.gz"
  tmp="$(mktemp -d)"
  trap 'rm -rf "${tmp}"' EXIT
  echo "xxh: downloading ${url}"
  curl -fsSL "${url}" | tar -xzf - -C "${tmp}"
  bin="${tmp}/xxh"
  [[ -f "${bin}" ]] || bin="$(find "${tmp}" -maxdepth 2 -type f -name xxh | head -n1 || true)"
  [[ -n "${bin}" && -f "${bin}" ]] || { echo "xxh: could not find xxh binary in archive" >&2; exit 1; }
  chmod +x "${bin}"
  install -m0755 "${bin}" "${DEST}/xxh"
  echo "xxh: installed ${DEST}/xxh"
  exit 0
fi

echo "xxh: no supported install method (need pipx, brew, or Linux x86_64)" >&2
exit 0
