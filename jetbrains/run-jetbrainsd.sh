#!/usr/bin/env bash
set -euo pipefail
dir="${XDG_DATA_HOME:-$HOME/.local/share}/JetBrains/Daemon/bundles/current/jetbrainsd/bin"
ver="$(tr -d '[:space:]' <"$dir/VERSION")"
exec "$dir/jetbrainsd" run --require-version "$ver" --no-shutdown-on-disconnect "$@"
