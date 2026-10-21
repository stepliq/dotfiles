#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0

command -v systemctl >/dev/null 2>&1 || exit 0

daemon_bin="${XDG_DATA_HOME:-$HOME/.local/share}/JetBrains/Daemon/bundles/current/jetbrainsd/bin/jetbrainsd"
unit_dst="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/jetbrainsd.service"
wrapper_dst="$HOME/.local/libexec/run-jetbrainsd"

[[ -x "$daemon_bin" ]] || exit 0
[[ -e "$unit_dst" && -e "$wrapper_dst" ]] || {
  echo "enable-jetbrainsd: missing unit/wrapper links — run ./install first" >&2
  exit 1
}

if pgrep -x jetbrainsd >/dev/null 2>&1; then
  systemctl --user stop jetbrainsd.service 2>/dev/null || true
  pkill -x jetbrainsd 2>/dev/null || true
  sleep 1
  pkill -9 -x jetbrainsd 2>/dev/null || true
fi

systemctl --user daemon-reload
systemctl --user enable --now jetbrainsd.service
systemctl --user restart jetbrainsd.service
