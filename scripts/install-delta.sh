#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
# shellcheck source=lib/github-bin.sh
source "${ROOT}/lib/github-bin.sh"
dotfiles_skip_apps

VERSION="${DELTA_VERSION:-0.19.2}"
DEST="$(dotfiles_dest_bin)"
if [[ -x "${DEST}/delta" ]]; then
  dotfiles_log "already installed ($("${DEST}/delta" --version 2>/dev/null | head -n1 || true))"
  exit 0
fi

case "$(uname -s):$(uname -m)" in
  Linux:x86_64) suffix=x86_64-unknown-linux-gnu ;;
  Linux:aarch64) suffix=aarch64-unknown-linux-gnu ;;
  Darwin:x86_64) suffix=x86_64-apple-darwin ;;
  Darwin:arm64) suffix=aarch64-apple-darwin ;;
  *) dotfiles_die "unsupported platform: $(uname -s)/$(uname -m)" ;;
esac

dotfiles_install_from_url \
  "https://github.com/dandavison/delta/releases/download/${VERSION}/delta-${VERSION}-${suffix}.tar.gz" \
  delta "${DEST}"
