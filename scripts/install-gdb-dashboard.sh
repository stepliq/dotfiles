#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0

DEST="${XDG_DATA_HOME:-$HOME/.local/share}/gdb-dashboard"
URL="${GDB_DASHBOARD_URL:-https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/master/.gdbinit}"

if [[ -f "${DEST}/.gdbinit" ]]; then
  echo "gdb-dashboard: already present at ${DEST}/.gdbinit"
  exit 0
fi

mkdir -p "${DEST}"
tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT
echo "gdb-dashboard: downloading ${URL}"
if ! curl -fsSL --connect-timeout 10 --max-time 120 "${URL}" -o "${tmp}"; then
  echo "gdb-dashboard: download failed (continuing)" >&2
  exit 0
fi
install -m 644 "${tmp}" "${DEST}/.gdbinit"
echo "gdb-dashboard: installed ${DEST}/.gdbinit"
