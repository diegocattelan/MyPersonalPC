# Programmable completion for Bash.
if [ -r /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi

# Bash completions installed by Homebrew packages.
if [ -d /home/linuxbrew/.linuxbrew/etc/bash_completion.d ]; then
  for file in /home/linuxbrew/.linuxbrew/etc/bash_completion.d/*; do
    [ -r "$file" ] && . "$file"
  done
fi

# paru ships its completion as paru.bash, which is not always picked up by
# bash-completion's lazy loader.
if [ -r /usr/share/bash-completion/completions/paru.bash ]; then
  . /usr/share/bash-completion/completions/paru.bash
fi

# fzf shell shortcuts:
#   Ctrl-r: search command history
#   Ctrl-t: insert a selected file or directory
#   Alt-c:  cd into a selected directory
if [ -r /usr/share/fzf/completion.bash ]; then
  . /usr/share/fzf/completion.bash
fi

if [ -r /usr/share/fzf/key-bindings.bash ]; then
  . /usr/share/fzf/key-bindings.bash
fi
