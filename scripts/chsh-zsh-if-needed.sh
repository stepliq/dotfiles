#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0
[[ -t 0 ]] || { echo "chsh: non-interactive — skip"; exit 0; }
Z="$(command -v zsh)"
[[ -n "$Z" && -x "$Z" ]] || { echo "chsh: zsh not in PATH" >&2; exit 1; }
C="$(readlink -f "${SHELL}" 2>/dev/null || echo "$SHELL")"
T="$(readlink -f "$Z")"
[[ $C == "$T" ]] && exit 0
grep -qxF "$Z" /etc/shells 2>/dev/null || echo "chsh: $Z not in /etc/shells" >&2
exec chsh -s "$Z"
