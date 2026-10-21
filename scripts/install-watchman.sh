#!/usr/bin/env bash
set -euo pipefail
[[ -n ${DOTFILES_SKIP_APPS:-} ]] && exit 0

VERSION="${WATCHMAN_VERSION:-2026.07.27.00}"
PREFIX="${HOME}/.local/opt/watchman"
DEST_BIN="${HOME}/.local/bin"
STATE_DIR="${HOME}/.local/var/run/watchman"

if command -v watchman >/dev/null 2>&1; then
  echo "watchman: already installed ($(watchman version 2>/dev/null | head -n1 || watchman --help 2>/dev/null | head -n1 || true))"
  exit 0
fi

arch="$(uname -m)"
os="$(uname -s)"
platform=

if [[ "${os}" == "Linux" ]]; then
  [[ "${arch}" == "x86_64" ]] || { echo "watchman: prebuilt linux zip is x86_64-only (got ${arch})" >&2; exit 0; }
  platform=linux
elif [[ "${os}" == "Darwin" ]]; then
  platform=macos
else
  echo "watchman: unsupported OS: ${os}" >&2
  exit 0
fi

url="https://github.com/facebook/watchman/releases/download/v${VERSION}/watchman-v${VERSION}-${platform}.zip"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

echo "watchman: downloading ${url}"
if ! curl -fsSL "${url}" -o "${tmp}/watchman.zip"; then
  echo "watchman: download failed (tag may lack ${platform} assets)" >&2
  exit 1
fi

unzip -oq "${tmp}/watchman.zip" -d "${tmp}"
root="$(find "${tmp}" -maxdepth 1 -type d -name "watchman-v${VERSION}-${platform}" | head -n1 || true)"
[[ -n "${root}" && -d "${root}/bin" ]] || { echo "watchman: unexpected archive layout" >&2; exit 1; }

rm -rf "${PREFIX}"
mkdir -p "${PREFIX}/bin" "${PREFIX}/lib" "${DEST_BIN}" "${STATE_DIR}"
chmod 2777 "${STATE_DIR}" 2>/dev/null || chmod 777 "${STATE_DIR}"

cp -a "${root}/bin/." "${PREFIX}/bin/"
if [[ -d "${root}/lib" ]]; then
  cp -a "${root}/lib/." "${PREFIX}/lib/"
fi
chmod 755 "${PREFIX}/bin/watchman" "${PREFIX}/bin/"* 2>/dev/null || true

cat > "${DEST_BIN}/watchman" <<EOF
#!/usr/bin/env bash
export LD_LIBRARY_PATH="${PREFIX}/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
export DYLD_LIBRARY_PATH="${PREFIX}/lib\${DYLD_LIBRARY_PATH:+:\$DYLD_LIBRARY_PATH}"
export WATCHMAN_STATE_DIR="${STATE_DIR}"
exec "${PREFIX}/bin/watchman" "\$@"
EOF
chmod 755 "${DEST_BIN}/watchman"

if [[ -x "${PREFIX}/bin/watchmanctl" ]]; then
  cat > "${DEST_BIN}/watchmanctl" <<EOF
#!/usr/bin/env bash
export LD_LIBRARY_PATH="${PREFIX}/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
export DYLD_LIBRARY_PATH="${PREFIX}/lib\${DYLD_LIBRARY_PATH:+:\$DYLD_LIBRARY_PATH}"
exec "${PREFIX}/bin/watchmanctl" "\$@"
EOF
  chmod 755 "${DEST_BIN}/watchmanctl"
fi

echo "watchman: installed ${DEST_BIN}/watchman (v${VERSION}, libs in ${PREFIX}/lib)"
