#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps
dotfiles_have_cmd subl && exit 0

if dotfiles_have_cmd dnf; then
  sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
  ST_REPO=https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
  if [[ ! -f /etc/yum.repos.d/sublime-text.repo ]]; then
    if ! sudo dnf config-manager addrepo --from-repofile="$ST_REPO" 2>/dev/null; then
      sudo dnf config-manager --add-repo "$ST_REPO"
    fi
  fi
  sudo dnf install -y sublime-text
elif dotfiles_have_cmd apt-get; then
  sudo install -d -m0755 /etc/apt/keyrings
  wget -qO- https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc >/dev/null
  printf '%s\n' \
    'Types: deb' \
    'URIs: https://download.sublimetext.com/' \
    'Suites: apt/stable/' \
    'Signed-By: /etc/apt/keyrings/sublimehq-pub.asc' \
    | sudo tee /etc/apt/sources.list.d/sublime-text.sources >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y sublime-text
else
  dotfiles_die "unsupported OS"
fi
