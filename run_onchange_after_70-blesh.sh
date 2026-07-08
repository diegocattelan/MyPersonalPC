#!/usr/bin/env bash
set -euo pipefail

version="0.4.0-devel3"
archive_version="${version}-2"
url="https://github.com/akinomyoga/ble.sh/releases/download/v${version}/ble-${archive_version}.tar.xz"
target="${HOME}/.local/share/blesh"
stamp="${target}/.blesh-version"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

install_blesh() {
  if [[ -r "${target}/ble.sh" ]] &&
     [[ -f "${stamp}" ]] &&
     grep -qx "${archive_version}" "${stamp}"; then
    return 0
  fi

  require_command curl
  require_command tar

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "${tmpdir}"' EXIT

  curl -L --fail -o "${tmpdir}/ble.tar.xz" "${url}"
  mkdir -p "${tmpdir}/extract"
  tar -xJf "${tmpdir}/ble.tar.xz" -C "${tmpdir}/extract"

  src="${tmpdir}/extract/ble-${version}"
  if [[ ! -r "${src}/ble.sh" ]]; then
    printf 'Downloaded ble.sh archive did not contain expected file: %s\n' "${src}/ble.sh" >&2
    exit 1
  fi

  mkdir -p "$(dirname "${target}")"
  if [[ -e "${target}" ]]; then
    mv "${target}" "${target}.backup-$(date +%Y%m%d-%H%M%S)"
  fi

  mv "${src}" "${target}"
  printf '%s\n' "${archive_version}" > "${stamp}"
}

install_blesh
