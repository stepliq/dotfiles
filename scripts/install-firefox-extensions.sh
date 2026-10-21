#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps

dotfiles_have_cmd firefox || exit 0

LIST="${DOTFILES_FIREFOX_EXTENSIONS_LIST:-${ROOT}/../firefox/extensions.list}"
[[ -f $LIST ]] || dotfiles_die "missing extensions list: $LIST"

if [[ -d /etc/firefox-esr && ! -d /etc/firefox ]]; then
  policies_dir=/etc/firefox-esr/policies
else
  policies_dir=/etc/firefox/policies
fi
policies_file="${policies_dir}/policies.json"

extensions=()
while IFS= read -r line || [[ -n $line ]]; do
  line="${line%%#*}"
  line="${line//[[:space:]]/}"
  [[ -n $line ]] || continue
  extensions+=("$line")
done < "$LIST"

[[ ${#extensions[@]} -ge 1 ]] || { dotfiles_log "no extensions listed"; exit 0; }

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

python3 - "$tmp" "$policies_file" "${extensions[@]}" <<'PY'
import json
import sys
from pathlib import Path

out = Path(sys.argv[1])
existing_path = Path(sys.argv[2])
entries = sys.argv[3:]

policies = {"policies": {}}
if existing_path.is_file():
    try:
        loaded = json.loads(existing_path.read_text())
        if isinstance(loaded, dict):
            policies = loaded
    except json.JSONDecodeError:
        pass

policies.setdefault("policies", {})
settings = policies["policies"].setdefault("ExtensionSettings", {})

for entry in entries:
    if "|" not in entry:
        raise SystemExit(f"bad extensions.list entry: {entry}")
    addon_id, slug = entry.split("|", 1)
    settings[addon_id] = {
        "installation_mode": "normal_installed",
        "install_url": (
            f"https://addons.mozilla.org/firefox/downloads/latest/{slug}/latest.xpi"
        ),
    }

out.write_text(json.dumps(policies, indent=2) + "\n")
PY

if [[ -f $policies_file ]] && cmp -s "$tmp" "$policies_file"; then
  dotfiles_log "already up to date ($policies_file)"
  exit 0
fi

dotfiles_log "installing ${#extensions[@]} extensions via $policies_file"
if mkdir -p "$policies_dir" 2>/dev/null && install -m0644 "$tmp" "$policies_file" 2>/dev/null; then
  :
else
  sudo mkdir -p "$policies_dir"
  sudo install -m0644 "$tmp" "$policies_file"
fi

dotfiles_log "restart Firefox to apply extensions"
