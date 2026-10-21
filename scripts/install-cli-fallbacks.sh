#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps
exec env PYTHONPATH="${ROOT}/lib${PYTHONPATH:+:$PYTHONPATH}" python3 "${ROOT}/lib/cli_fallbacks.py"
