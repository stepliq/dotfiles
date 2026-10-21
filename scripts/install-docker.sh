#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps
REAL_USER="${SUDO_USER:-$USER}"

if ! dotfiles_have_cmd docker; then
  tmp="$(mktemp /tmp/get-docker.XXXXXX.sh)"
  trap 'rm -f "$tmp"' EXIT
  curl -fsSL https://get.docker.com -o "$tmp"
  sudo sh "$tmp"
fi

if getent group docker >/dev/null 2>&1; then
  if ! id -nG "$REAL_USER" | grep -qw docker; then
    sudo usermod -aG docker "$REAL_USER"
    dotfiles_warn "added $REAL_USER to group docker — log out and back in (or newgrp docker) to use docker without sudo."
  fi
fi
