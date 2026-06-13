# Enhanced Bash line editor: autosuggestions, syntax highlighting and better completion.
# Keep this late in the Bash startup sequence so it can wrap readline/completion.
if [[ $- == *i* && -t 0 && -t 1 ]]; then
  __bashrc_blesh_file=
  if [ -r /usr/share/blesh/ble.sh ]; then
    __bashrc_blesh_file=/usr/share/blesh/ble.sh
  elif [ -r "$HOME/.local/share/blesh/ble.sh" ]; then
    __bashrc_blesh_file=$HOME/.local/share/blesh/ble.sh
  fi

  if [ -n "${XDG_RUNTIME_DIR-}" ] && [ ! -w "$XDG_RUNTIME_DIR" ]; then
    __bashrc_blesh_xdg_runtime_dir=$XDG_RUNTIME_DIR
    unset XDG_RUNTIME_DIR
    [ -n "$__bashrc_blesh_file" ] && . "$__bashrc_blesh_file"
    export XDG_RUNTIME_DIR=$__bashrc_blesh_xdg_runtime_dir
    unset __bashrc_blesh_xdg_runtime_dir
  else
    [ -n "$__bashrc_blesh_file" ] && . "$__bashrc_blesh_file"
  fi

  unset __bashrc_blesh_file
fi
