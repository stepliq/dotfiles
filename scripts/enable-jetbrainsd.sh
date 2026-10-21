#!/usr/bin/env bash
set -euo pipefail

command -v systemctl >/dev/null 2>&1 || exit 0

daemon_bin="${XDG_DATA_HOME:-$HOME/.local/share}/JetBrains/Daemon/bundles/current/jetbrainsd/bin/jetbrainsd"
root="$(cd "$(dirname "$0")/.." && pwd)"
unit_src="$root/jetbrains/jetbrainsd.service"
unit_dst="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/jetbrainsd.service"
wrapper_src="$root/jetbrains/run-jetbrainsd.sh"
wrapper_dst="$HOME/.local/libexec/run-jetbrainsd"

[[ -x "$daemon_bin" ]] || exit 0
if [[ ! -f "$unit_src" ]]; then
  echo "enable-jetbrainsd: missing $unit_src" >&2
  exit 1
fi
if [[ ! -f "$wrapper_src" ]]; then
  echo "enable-jetbrainsd: missing $wrapper_src" >&2
  exit 1
fi

mkdir -p "$(dirname "$unit_dst")" "$(dirname "$wrapper_dst")"
ln -sfn "$wrapper_src" "$wrapper_dst"
if [[ -L "$unit_dst" || ! -e "$unit_dst" ]]; then
  ln -sfn "$unit_src" "$unit_dst"
elif ! cmp -s "$unit_src" "$unit_dst"; then
  install -m 644 "$unit_src" "$unit_dst"
fi

if pgrep -x jetbrainsd >/dev/null 2>&1; then
  systemctl --user stop jetbrainsd.service 2>/dev/null || true
  pkill -x jetbrainsd 2>/dev/null || true
  sleep 1
  pkill -9 -x jetbrainsd 2>/dev/null || true
fi

systemctl --user daemon-reload
systemctl --user enable --now jetbrainsd.service
systemctl --user restart jetbrainsd.service
