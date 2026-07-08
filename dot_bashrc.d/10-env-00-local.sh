__bashrc_brew_bin_linux() {
  [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && printf '%s\n' /home/linuxbrew/.linuxbrew/bin/brew
}

__bashrc_brew_bin_macos() {
  if [ -x /opt/homebrew/bin/brew ]; then
    printf '%s\n' /opt/homebrew/bin/brew
  elif [ -x /usr/local/bin/brew ]; then
    printf '%s\n' /usr/local/bin/brew
  fi
}

__bashrc_brew_bin() {
  case "$(uname -s 2>/dev/null || printf unknown)" in
    Darwin) __bashrc_brew_bin_macos ;;
    Linux) __bashrc_brew_bin_linux ;;
    *)
      __bashrc_brew_bin_macos
      __bashrc_brew_bin_linux
      ;;
  esac | sed -n '1p'
}

__bashrc_source_nvm() {
  export NVM_DIR="$HOME/.nvm"

  if [ -n "${HOMEBREW_PREFIX:-}" ]; then
    [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && . "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
    [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && . "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
  fi

  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}

__bashrc_brew_bin_result="$(__bashrc_brew_bin)"
if [ -n "$__bashrc_brew_bin_result" ]; then
  eval "$("$__bashrc_brew_bin_result" shellenv)"
fi

__bashrc_source_nvm

unset __bashrc_brew_bin_result
unset -f __bashrc_brew_bin_linux __bashrc_brew_bin_macos __bashrc_brew_bin __bashrc_source_nvm
