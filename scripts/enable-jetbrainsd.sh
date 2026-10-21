#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps
dotfiles_have_cmd systemctl || exit 0

daemon_bin="${XDG_DATA_HOME:-$HOME/.local/share}/JetBrains/Daemon/bundles/current/jetbrainsd/bin/jetbrainsd"
unit_dst="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/jetbrainsd.service"
wrapper_dst="$HOME/.local/libexec/run-jetbrainsd"

[[ -x "$daemon_bin" ]] || exit 0
[[ -e "$unit_dst" && -e "$wrapper_dst" ]] || dotfiles_die "missing unit/wrapper links — run ./install first"

if pgrep -x jetbrainsd >/dev/null 2>&1; then
  systemctl --user stop jetbrainsd.service 2>/dev/null || true
  pkill -x jetbrainsd 2>/dev/null || true
  sleep 1
  pkill -9 -x jetbrainsd 2>/dev/null || true
fi

systemctl --user daemon-reload
systemctl --user enable --now jetbrainsd.service
systemctl --user restart jetbrainsd.service
