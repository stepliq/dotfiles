#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps

dotfiles_have_cmd gammastep-indicator || dotfiles_have_cmd gammastep || exit 0
dotfiles_have_cmd systemctl || exit 0

systemctl --user disable --now redshift.service redshift-gtk.service 2>/dev/null || true

session="${XDG_SESSION_TYPE:-}"
if [[ -z "$session" && -n "${WAYLAND_DISPLAY:-}" ]]; then
  session=wayland
elif [[ -z "$session" && -n "${DISPLAY:-}" ]]; then
  session=x11
fi

case "$session" in
  wayland) method=wayland ;;
  *) method=randr ;;
esac

write_method_dropin() {
  local unit=$1 binary=$2
  local dropin_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/${unit}.service.d"
  mkdir -p "$dropin_dir"
  cat >"$dropin_dir/method.conf" <<EOF
[Service]
ExecStart=
ExecStart=${binary} -m ${method}
Restart=always
RestartSec=2
EOF
}

systemctl --user disable --now gammastep.service 2>/dev/null || true

if dotfiles_have_cmd gammastep-indicator; then
  write_method_dropin gammastep-indicator /usr/bin/gammastep-indicator
  rm -f "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/gammastep.service.d/method.conf"
  unit=gammastep-indicator
else
  write_method_dropin gammastep /usr/bin/gammastep
  unit=gammastep
fi

systemctl --user daemon-reload
systemctl --user enable --now "${unit}.service"
systemctl --user restart "${unit}.service"
