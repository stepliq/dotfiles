#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0
command -v ghostty >/dev/null 2>&1 && exit 0

if command -v dnf >/dev/null 2>&1; then
  sudo dnf -y copr enable scottames/ghostty
  sudo dnf install -y ghostty
elif command -v apt-get >/dev/null 2>&1; then
  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"; then
    echo "install-ghostty: ubuntu installer failed (continuing)" >&2
    exit 0
  fi
else
  echo "install-ghostty: unsupported OS" >&2
  exit 1
fi
