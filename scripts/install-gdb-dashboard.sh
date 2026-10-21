#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/gdb-dashboard"
URL="${GDB_DASHBOARD_URL:-https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/master/.gdbinit}"

if [[ -f "${DEST}/.gdbinit" ]]; then
  dotfiles_log "already present at ${DEST}/.gdbinit"
  exit 0
fi

mkdir -p "${DEST}"
tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT
dotfiles_log "downloading ${URL}"
if ! curl -fsSL --connect-timeout 10 --max-time 120 "${URL}" -o "${tmp}"; then
  dotfiles_warn "download failed (continuing)"
  exit 0
fi
install -m 644 "${tmp}" "${DEST}/.gdbinit"
dotfiles_log "installed ${DEST}/.gdbinit"
