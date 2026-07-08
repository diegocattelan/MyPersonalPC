#!/bin/sh
set -eu

install_from_stdin() {
  target="$1"
  mode="$2"
  tmp="$(mktemp)"
  cat > "$tmp"

  if [ "$(id -u)" -eq 0 ]; then
    install -Dm"$mode" "$tmp" "$target"
  else
    sudo install -Dm"$mode" "$tmp" "$target"
  fi

  rm -f "$tmp"
}

apply_jetbrains_limits_linux() {
  install_from_stdin /etc/sysctl.d/90-jetbrains-idea.conf 644 <<'EOF'
# Raise limits for JetBrains IDE indexing and file watchers on large projects.
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 2048
fs.inotify.max_queued_events = 32768
EOF

  install_from_stdin /etc/security/limits.d/90-jetbrains-idea.conf 644 <<'EOF'
# Give the local user enough file descriptors for JetBrains IDEs.
birbante soft nofile 1048576
birbante hard nofile 1048576
EOF

  install_from_stdin /etc/systemd/user.conf.d/90-jetbrains-idea.conf 644 <<'EOF'
[Manager]
DefaultLimitNOFILE=1048576
EOF

  if [ "$(id -u)" -eq 0 ]; then
    sysctl -p /etc/sysctl.d/90-jetbrains-idea.conf
  else
    sudo sysctl -p /etc/sysctl.d/90-jetbrains-idea.conf
  fi
}

apply_jetbrains_limits_macos() {
  printf '%s\n' "Skipping JetBrains Linux limit files on macOS."
}

apply_jetbrains_limits() {
  case "$(uname -s 2>/dev/null || printf unknown)" in
    Darwin) apply_jetbrains_limits_macos ;;
    Linux) apply_jetbrains_limits_linux ;;
    *) apply_jetbrains_limits_linux ;;
  esac
}

apply_jetbrains_limits
