#!/usr/bin/env bash
set -euo pipefail

version="3.4.0"
font="FiraCode"
url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${font}.zip"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

install_font_archive() {
  target="$1"
  stamp="${target}/.nerd-fonts-version"

  if [[ -f "${stamp}" ]] && grep -qx "${version}" "${stamp}"; then
    return 0
  fi

  require_command curl
  require_command unzip

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "${tmpdir}"' EXIT

  curl -L --fail -o "${tmpdir}/${font}.zip" "${url}"
  mkdir -p "${target}"
  unzip -o -q "${tmpdir}/${font}.zip" -d "${target}"
  printf '%s\n' "${version}" > "${stamp}"
}

install_firacode_linux() {
  target="${HOME}/.local/share/fonts/nerd-fonts/${font}"
  install_font_archive "${target}"

  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "${target}" >/dev/null
  fi
}

install_firacode_macos() {
  target="${HOME}/Library/Fonts/NerdFonts/${font}"
  install_font_archive "${target}"
}

install_firacode() {
  case "$(uname -s 2>/dev/null || printf unknown)" in
    Darwin) install_firacode_macos ;;
    Linux) install_firacode_linux ;;
    *) install_firacode_linux ;;
  esac
}

install_firacode
