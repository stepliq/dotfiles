#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
dotfiles_skip_apps

VERSION="${WATCHMAN_VERSION:-2026.07.27.00}"
PREFIX="${HOME}/.local/opt/watchman"
DEST_BIN="$(dotfiles_dest_bin)"
STATE_DIR="${HOME}/.local/var/run/watchman"

if dotfiles_have_cmd watchman; then
  dotfiles_log "already installed ($(watchman version 2>/dev/null | head -n1 || watchman --help 2>/dev/null | head -n1 || true))"
  exit 0
fi

case "$(uname -s):$(uname -m)" in
  Linux:x86_64) platform=linux ;;
  Darwin:*) platform=macos ;;
  Linux:*)
    dotfiles_warn "prebuilt linux zip is x86_64-only (got $(uname -m))"
    exit 0
    ;;
  *)
    dotfiles_warn "unsupported OS: $(uname -s)"
    exit 0
    ;;
esac

url="https://github.com/facebook/watchman/releases/download/v${VERSION}/watchman-v${VERSION}-${platform}.zip"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

dotfiles_log "downloading ${url}"
if ! curl -fsSL "${url}" -o "${tmp}/watchman.zip"; then
  dotfiles_die "download failed (tag may lack ${platform} assets)"
fi

unzip -oq "${tmp}/watchman.zip" -d "${tmp}"
root_dir="$(find "${tmp}" -maxdepth 1 -type d -name "watchman-v${VERSION}-${platform}" | head -n1 || true)"
[[ -n "${root_dir}" && -d "${root_dir}/bin" ]] || dotfiles_die "unexpected archive layout"

rm -rf "${PREFIX}"
mkdir -p "${PREFIX}/bin" "${PREFIX}/lib" "${STATE_DIR}"
chmod 2777 "${STATE_DIR}" 2>/dev/null || chmod 777 "${STATE_DIR}"

cp -a "${root_dir}/bin/." "${PREFIX}/bin/"
if [[ -d "${root_dir}/lib" ]]; then
  cp -a "${root_dir}/lib/." "${PREFIX}/lib/"
fi
chmod 755 "${PREFIX}/bin/watchman" "${PREFIX}/bin/"* 2>/dev/null || true

write_wrapper() {
  local name=$1
  {
    echo '#!/usr/bin/env bash'
    echo "export LD_LIBRARY_PATH=\"${PREFIX}/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}\""
    echo "export DYLD_LIBRARY_PATH=\"${PREFIX}/lib\${DYLD_LIBRARY_PATH:+:\$DYLD_LIBRARY_PATH}\""
    if [[ $name == watchman ]]; then
      echo "export WATCHMAN_STATE_DIR=\"${STATE_DIR}\""
    fi
    echo "exec \"${PREFIX}/bin/${name}\" \"\$@\""
  } > "${DEST_BIN}/${name}"
  chmod 755 "${DEST_BIN}/${name}"
}

write_wrapper watchman
[[ -x "${PREFIX}/bin/watchmanctl" ]] && write_wrapper watchmanctl

dotfiles_log "installed ${DEST_BIN}/watchman (v${VERSION}, libs in ${PREFIX}/lib)"
