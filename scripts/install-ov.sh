#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
# shellcheck source=lib/github-bin.sh
source "${ROOT}/lib/github-bin.sh"
dotfiles_skip_apps

VERSION="${OV_VERSION:-0.55.0}"
DEST="$(dotfiles_dest_bin)"
if dotfiles_have_cmd ov; then
  dotfiles_log "already installed ($(ov --version 2>/dev/null | head -n1 || true))"
  exit 0
fi

case "$(uname -s):$(uname -m)" in
  Linux:x86_64) suffix=linux_amd64 ;;
  Linux:aarch64) suffix=linux_arm64 ;;
  Linux:armv7l|Linux:armv6l) suffix=linux_arm ;;
  Linux:i386|Linux:i686) suffix=linux_386 ;;
  Darwin:x86_64) suffix=darwin_amd64 ;;
  Darwin:arm64) suffix=darwin_arm64 ;;
  *)
    dotfiles_warn "unsupported platform: $(uname -s)/$(uname -m)"
    exit 0
    ;;
esac

dotfiles_install_from_url \
  "https://github.com/noborus/ov/releases/download/v${VERSION}/ov_${VERSION}_${suffix}.zip" \
  ov "${DEST}"
