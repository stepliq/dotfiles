#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
# shellcheck source=lib/github-bin.sh
source "${ROOT}/lib/github-bin.sh"
dotfiles_skip_apps

version="${LAZYDOCKER_VERSION:-0.25.2}"
dest="$(dotfiles_dest_bin)"
dotfiles_have_cmd lazydocker && exit 0

case "$(uname -s):$(uname -m)" in
  Linux:x86_64) suffix=Linux_x86_64 ;;
  Linux:aarch64) suffix=Linux_arm64 ;;
  Linux:armv7l) suffix=Linux_armv7 ;;
  Darwin:x86_64) suffix=Darwin_x86_64 ;;
  Darwin:arm64) suffix=Darwin_arm64 ;;
  *) exit 0 ;;
esac

dotfiles_install_from_url   "https://github.com/jesseduffield/lazydocker/releases/download/v${version}/lazydocker_${version}_${suffix}.tar.gz"   lazydocker "$dest"
