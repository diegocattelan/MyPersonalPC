#!/bin/sh
set -eu

src="${HOME}/.local/share/terminfo-src/xterm-kitty.terminfo"
out="${HOME}/.terminfo"

mkdir -p "$out"
tic -x -o "$out" "$src"
