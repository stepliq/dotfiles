#!/usr/bin/env bash
# curl -fsSL https://get.docker.com | sh — then add user to group docker
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0

REAL_USER="${SUDO_USER:-$USER}"

if ! command -v docker >/dev/null 2>&1; then
  tmp="$(mktemp /tmp/get-docker.XXXXXX.sh)"
  trap 'rm -f "$tmp"' EXIT
  curl -fsSL https://get.docker.com -o "$tmp"
  sudo sh "$tmp"
fi

if getent group docker >/dev/null 2>&1; then
  if ! id -nG "$REAL_USER" | grep -qw docker; then
    sudo usermod -aG docker "$REAL_USER"
    echo "install-docker: added $REAL_USER to group docker — log out and back in (or newgrp docker) to use docker without sudo." >&2
  fi
fi
