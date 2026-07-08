# Start tmux from interactive terminal shells.
if [[ $- != *i* ]] \
  || [[ -n "${TMUX:-}" ]] \
  || [[ -n "${NO_AUTO_TMUX:-}" ]] \
  || ! [[ -t 0 && -t 1 ]] \
  || ! command -v tmux >/dev/null 2>&1; then
  return 0
fi

if [[ -n "${SSH_TTY:-}" || -n "${SSH_CONNECTION:-}" ]]; then
  [[ -n "${NO_SSH_TMUX:-}" ]] && return 0
  exec tmux new-session -A -s ssh
fi

exec tmux new-session
