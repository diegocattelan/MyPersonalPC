# Attach interactive SSH logins to one persistent tmux session.
if [[ $- == *i* ]] \
  && [[ -n "${SSH_TTY:-}" || -n "${SSH_CONNECTION:-}" ]] \
  && [[ -z "${TMUX:-}" ]] \
  && [[ -z "${NO_SSH_TMUX:-}" ]] \
  && command -v tmux >/dev/null 2>&1; then
  exec tmux new-session -A -s ssh
fi
