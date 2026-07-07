#!/usr/bin/env bash
set -euo pipefail

version="3.4.0"
font="FiraCode"
url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${font}.zip"
target="${HOME}/.local/share/fonts/nerd-fonts/${font}"
stamp="${target}/.nerd-fonts-version"

if [[ -f "${stamp}" ]] && grep -qx "${version}" "${stamp}"; then
  exit 0
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

curl -L --fail -o "${tmpdir}/${font}.zip" "${url}"
mkdir -p "${target}"
unzip -o -q "${tmpdir}/${font}.zip" -d "${target}"
printf '%s\n' "${version}" > "${stamp}"
fc-cache -f "${target}" >/dev/null
