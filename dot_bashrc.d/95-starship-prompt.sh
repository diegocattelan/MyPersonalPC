if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CMD_STATUS=0
  eval "$(starship init bash)"
fi
