#!/usr/bin/env bash
# DOTFILES_VSCODE_CLI=code|cursor|codium  DOTFILES_VSCODE_EXT_TIMEOUT=300
set -uo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0
T="${DOTFILES_VSCODE_EXT_TIMEOUT:-180}"
EXT=(
  editorconfig.editorconfig ms-python.python ms-python.vscode-pylance
  ms-vscode.cpptools sobolevn.pustota subframe7536.custom-ui-style teabyii.ayu
)

cli() {
  if [[ -n ${DOTFILES_VSCODE_CLI:-} ]] && command -v "$DOTFILES_VSCODE_CLI" >/dev/null 2>&1; then
    echo "$DOTFILES_VSCODE_CLI"
    return
  fi
  for c in code codium cursor; do
    command -v "$c" >/dev/null 2>&1 && echo "$c" && return
  done
  return 1
}

run() {
  if command -v timeout >/dev/null 2>&1; then
    timeout --signal=TERM "$T" "$1" --install-extension "$2" --force </dev/null
  else
    "$1" --install-extension "$2" --force </dev/null
  fi
}

C="$(cli)" || exit 0
f=0
for e in "${EXT[@]}"; do run "$C" "$e" || f=1; done
if [[ $f -ne 0 ]]; then
  echo "vscode-extensions: some installs failed (continuing)" >&2
fi
exit 0
