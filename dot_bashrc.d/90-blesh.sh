# Enhanced Bash line editor: autosuggestions, syntax highlighting and better completion.
# Source without attaching here; 99-blesh-attach.sh attaches after Starship so
# ble.sh sees the final prompt.
if [[ $- == *i* && -t 0 && -t 1 ]]; then
  __bashrc_blesh_file=
  if [ -r "$HOME/.local/share/blesh/ble.sh" ]; then
    __bashrc_blesh_file=$HOME/.local/share/blesh/ble.sh
  elif [ -r /usr/share/blesh/ble.sh ]; then
    __bashrc_blesh_file=/usr/share/blesh/ble.sh
  fi

  __bashrc_source_blesh() {
    [ -n "$__bashrc_blesh_file" ] || return 0
    . "$__bashrc_blesh_file" --attach=none

    # ble.sh 0.4+ preserves Starship's 24-bit LCARS colors when truecolor
    # prompt parsing is enabled explicitly.
    if [ -n "${bleopt_term_true_colors+x}" ] && command -v bleopt >/dev/null 2>&1; then
      bleopt term_true_colors=semicolon
    fi
  }

  if [ -n "${XDG_RUNTIME_DIR-}" ] && [ ! -w "$XDG_RUNTIME_DIR" ]; then
    __bashrc_blesh_xdg_runtime_dir=$XDG_RUNTIME_DIR
    unset XDG_RUNTIME_DIR
    __bashrc_source_blesh
    export XDG_RUNTIME_DIR=$__bashrc_blesh_xdg_runtime_dir
    unset __bashrc_blesh_xdg_runtime_dir
  else
    __bashrc_source_blesh
  fi

  unset __bashrc_blesh_file
  unset -f __bashrc_source_blesh
fi
