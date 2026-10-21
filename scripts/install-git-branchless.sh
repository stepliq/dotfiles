#!/usr/bin/env bash
set -euo pipefail

if command -v git-branchless >/dev/null 2>&1 || git branchless --help >/dev/null 2>&1; then
  echo "git-branchless: already installed"
  exit 0
fi

export PATH="${HOME}/.cargo/bin:${PATH}"
if ! command -v cargo >/dev/null 2>&1; then
  echo "git-branchless: cargo not found; skip cargo fallback" >&2
  exit 0
fi

echo "git-branchless: installing via cargo"
cargo install --locked git-branchless
echo "git-branchless: installed ($(command -v git-branchless || echo "${HOME}/.cargo/bin/git-branchless"))"
echo "git-branchless: run 'git branchless init' inside each repo you want to use"
