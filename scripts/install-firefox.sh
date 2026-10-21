#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps

dotfiles_have_cmd firefox && exit 0

if dotfiles_have_cmd dnf; then
  sudo dnf install -y firefox
elif dotfiles_have_cmd apt-get; then
  sudo apt-get update -qq
  sudo apt-get install -y firefox || sudo apt-get install -y firefox-esr
elif dotfiles_have_cmd pacman; then
  sudo pacman -S --needed --noconfirm firefox
else
  dotfiles_die "unsupported OS (dnf/apt/pacman only)"
fi
