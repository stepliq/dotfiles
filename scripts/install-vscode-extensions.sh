#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps

timeout_secs="${DOTFILES_VSCODE_EXT_TIMEOUT:-180}"
extensions=(
  editorconfig.editorconfig
  ms-python.python
  ms-python.vscode-pylance
  ms-vscode.cpptools
  sobolevn.pustota
  subframe7536.custom-ui-style
  teabyii.ayu
)

find_cli() {
  if [[ -n ${DOTFILES_VSCODE_CLI:-} ]] && dotfiles_have_cmd "$DOTFILES_VSCODE_CLI"; then
    echo "$DOTFILES_VSCODE_CLI"
    return
  fi
  for cli in code codium cursor; do
    if dotfiles_have_cmd "$cli"; then
      echo "$cli"
      return
    fi
  done
  return 1
}

install_extension() {
  local cli=$1 extension=$2
  if dotfiles_have_cmd timeout; then
    timeout --signal=TERM "$timeout_secs" "$cli" --install-extension "$extension" --force </dev/null
  else
    "$cli" --install-extension "$extension" --force </dev/null
  fi
}

cli="$(find_cli)" || exit 0
failed=0
for extension in "${extensions[@]}"; do
  install_extension "$cli" "$extension" || failed=1
done
[[ $failed -eq 0 ]] || dotfiles_warn "some installs failed (continuing)"
exit 0
