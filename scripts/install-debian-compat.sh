#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/github-bin.sh
source "${ROOT}/lib/github-bin.sh"

dotfiles_ensure_symlink batcat bat
dotfiles_ensure_symlink fdfind fd
