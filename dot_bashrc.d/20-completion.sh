__bashrc_source_if_readable() {
  [ -r "$1" ] && . "$1"
}

__bashrc_source_readable_dir() {
  [ -d "$1" ] || return 0

  for file in "$1"/*; do
    [ -r "$file" ] && . "$file"
  done
}

__bashrc_completion_linux() {
  # Programmable completion for Bash.
  __bashrc_source_if_readable /usr/share/bash-completion/bash_completion

  # Bash completions installed by Linuxbrew packages.
  __bashrc_source_readable_dir /home/linuxbrew/.linuxbrew/etc/bash_completion.d

  # paru ships its completion as paru.bash, which is not always picked up by
  # bash-completion's lazy loader.
  __bashrc_source_if_readable /usr/share/bash-completion/completions/paru.bash

  # fzf shell shortcuts:
  #   Ctrl-r: search command history
  #   Ctrl-t: insert a selected file or directory
  #   Alt-c:  cd into a selected directory
  __bashrc_source_if_readable /usr/share/fzf/completion.bash
  __bashrc_source_if_readable /usr/share/fzf/key-bindings.bash
}

__bashrc_completion_macos() {
  if [ -n "${HOMEBREW_PREFIX:-}" ]; then
    __bashrc_source_if_readable "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
    __bashrc_source_readable_dir "$HOMEBREW_PREFIX/etc/bash_completion.d"
    __bashrc_source_if_readable "$HOMEBREW_PREFIX/opt/fzf/shell/completion.bash"
    __bashrc_source_if_readable "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.bash"
  fi
}

__bashrc_completion() {
  case "$(uname -s 2>/dev/null || printf unknown)" in
    Darwin) __bashrc_completion_macos ;;
    Linux) __bashrc_completion_linux ;;
    *)
      __bashrc_completion_macos
      __bashrc_completion_linux
      ;;
  esac
}

__bashrc_completion

unset -f __bashrc_source_if_readable __bashrc_source_readable_dir
unset -f __bashrc_completion_linux __bashrc_completion_macos __bashrc_completion
