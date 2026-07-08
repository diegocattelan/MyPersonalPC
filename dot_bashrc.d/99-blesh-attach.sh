# Attach ble.sh after prompt setup so autosuggestions and syntax highlighting
# work with Starship's final prompt.
if [[ $- == *i* && -t 0 && -t 1 ]] && command -v ble-attach >/dev/null 2>&1; then
  ble-attach
fi
