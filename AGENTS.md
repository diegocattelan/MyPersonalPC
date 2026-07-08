# Local Configuration Notes

This file is the single local `AGENTS.md` for this home directory. Keep project
or configuration notes here instead of scattering additional `AGENTS.md` files
under subdirectories.

## Operating Workflow

When the user asks Codex to change the local environment, treat the change as a
dotfiles/configuration change unless there is a clear reason not to.

For each environment change:

- make the requested change in the live home directory first
- update this `~/AGENTS.md` when the change creates new conventions, workflows,
  shortcuts, or maintenance notes
- add or update the affected files in chezmoi before finishing
- verify with the relevant tool, for example `niri validate` for niri changes
- commit and push the chezmoi repository automatically unless the user asks not
  to
- summarize the live files changed, the chezmoi source files updated, and the
  pushed commit

Shell scripts in dotfiles should run under Bash on macOS as well as Linux unless
they are explicitly Linux-only. Prefer POSIX-compatible shell where practical.
When behavior differs by OS, use a small routing function and put the divergent
logic in clearly named functions such as `*_linux` and `*_macos`; Linux-only
maintenance scripts should no-op explicitly on macOS rather than failing on
missing Linux paths or tools.

The chezmoi source directory is:

```text
~/.local/share/chezmoi
```

Use `chezmoi add <path>` for new or changed managed files, then check with:

```bash
chezmoi status
git -C ~/.local/share/chezmoi status --short
```

Use chezmoi's git wrapper for repository operations:

```bash
chezmoi git -- status --short
chezmoi git -- commit -m "<message>"
chezmoi git -- push
```

Git HTTPS authentication uses the Secret Service/libsecret credential helper:

```ini
[credential]
    helper = /usr/lib/git-core/git-credential-libsecret
```

This keeps GitHub credentials out of dotfiles. The first authenticated HTTPS
push may still need the user to provide GitHub credentials or a token
interactively; after that Git can retrieve them from the local keyring.

## Codex MCP Servers

Codex MCP server configuration is managed in:

```text
~/.codex/config.toml
```

The configured `chrome-devtools` MCP server runs through:

```bash
npx -y chrome-devtools-mcp@latest
```

Serena is installed as a uv tool:

```bash
uv tool install -p 3.13 serena-agent
```

The `serena`, `serena-agent`, and `serena-hooks` commands are exposed through
`~/.local/bin`, so keep that directory in the shell `PATH`. The global Serena
configuration lives in `~/.serena/serena_config.yml`, initialised with the LSP
backend by `serena init`.

Codex connects to Serena MCP over streamable HTTP:

```text
http://127.0.0.1:9121/mcp
```

The persistent user service is:

```bash
systemctl --user status serena-mcp.service
```

It starts Serena without an initial project so it does not scan the whole home
directory at login. The Serena web dashboard is enabled and opened on service
startup. When using Serena tools in a Codex session, activate the current
repository explicitly with Serena's `activate_project` tool. The service command
is:

```bash
/home/birbante/.local/bin/serena start-mcp-server --context=codex --transport streamable-http --host 127.0.0.1 --port 9121 --enable-web-dashboard true --open-web-dashboard true
```

## Niri Config

The local niri configuration lives in `~/.config/niri`.

The active top-level config is `~/.config/niri/config.kdl`. It only includes
smaller files from `~/.config/niri/cfg/`, so most changes should be made in the
relevant file there:

- `cfg/keybinds.kdl`: active keyboard shortcuts
- `cfg/keybinds-riepilogo.txt`: user-facing shortcut help opened by `Mod+Backslash`
- `cfg/autostart.kdl`: startup processes
- `cfg/input.kdl`: input devices and keyboard settings
- `cfg/display.kdl`: outputs
- `cfg/layout.kdl`: layout, borders, shadows, and geometry
- `cfg/rules.kdl`: window rules
- `cfg/misc.kdl`: environment and miscellaneous niri settings

### Input Behavior

The touchpad is configured in `~/.config/niri/cfg/input.kdl` with
`disabled-on-external-mouse`, so niri/libinput suppresses touchpad events while
an external mouse is connected. Keep this in the `touchpad` block rather than
adding a separate hotplug script.

Keyboard layouts are configured in `~/.config/niri/cfg/input.kdl` with XKB
layouts `it,us`. Use `Mod+Space` to switch between the Italian layout and the
English US layout. Caps Lock is configured as the Compose key with
`compose:caps`.

### Validation

After changing `~/.config/niri/cfg/keybinds.kdl` or any included niri
configuration file, run:

```bash
niri validate --config ~/.config/niri/config.kdl
```

If niri is running and the config validates, reload it with:

```bash
niri msg action load-config-file
```

### CachyOS GPU / NVIDIA

This host is a hybrid Intel/NVIDIA laptop. The internal eDP panel is on the
Intel DRM device, while the external HDMI output is on the NVIDIA DRM device.
The intended CachyOS-managed graphics profile is:

```text
nvidia-open-dkms.prime
intel-lpmd
intel
```

Keep CHWD as the owner of this GPU profile. Do not manually mix the profile with
the `nvidia-580xx-*`, `opencl-nvidia-580xx`, or `lib32-nvidia-580xx-*` packages;
the restored CachyOS stack uses the generic/open packages such as
`nvidia-utils`, `opencl-nvidia`, `lib32-nvidia-utils`,
`lib32-opencl-nvidia`, `linux-cachyos-nvidia-open`, and
`linux-cachyos-lts-nvidia-open`.

CHWD generates `/etc/mkinitcpio.conf.d/10-chwd.conf` with:

```text
MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

It also owns the NVIDIA RTD3 workaround files under `/etc/profile.d/` and
`/usr/lib/systemd/user-environment-generators/`, and enables
`nvidia-powerd.service` plus `switcheroo-control.service`. After changing the
GPU profile or NVIDIA packages, run `mkinitcpio -P` so the CachyOS/Limine boot
entries are refreshed, then reboot. If `nvidia-smi` reports a driver/library
version mismatch before rebooting, it usually means the userspace NVIDIA package
has changed while the currently loaded kernel module is still from the previous
boot.

Niri has previously rendered on the Intel render node while presenting the
external HDMI output through NVIDIA, which can trigger vblank warnings and
stutter on the external monitor. Use the stable NVIDIA by-path symlink in
`~/.config/niri/cfg/misc.kdl` instead of hardcoding a `renderD*` number, because
those numbers can change across boots:

```kdl
debug {
    render-drm-device "/dev/dri/by-path/pci-0000:01:00.0-render"
}
```

### Keybind Grammar

These shortcuts were adapted from the previous Dank Linux / DMS setup. Keep the
same key grammar where possible:

- `Mod`: navigation and basic launch actions
- `Mod+Shift`: extended navigation
- `Mod+Ctrl`: movement or positional changes
- `Mod+Alt`: non-positional state, layout, or session changes

Prefer normal letters and arrow keys. Avoid layout-specific or symbol keys such
as `grave`, accented keys, comma, slash, period, minus, equal, and similar unless
there is a strong reason.

Hardware and pointer inputs such as `XF86*`, `Print`, and `WheelScroll*` are
acceptable exceptions.

### Dank / DMS Compatibility

The old backup came from Dank Linux / Dank Material Shell, but this installation
does not currently have `dms` or `kitty` installed. Do not copy old DMS commands
blindly into `~/.config/niri/cfg/keybinds.kdl`, because they may validate as
niri syntax while still doing nothing at runtime.

Use Noctalia IPC equivalents where they exist:

- launcher: `qs -c noctalia-shell ipc call launcher toggle`
- settings: `qs -c noctalia-shell ipc call settings toggle`
- notifications: `qs -c noctalia-shell ipc call notifications toggleHistory`
- clipboard: `qs -c noctalia-shell ipc call plugin:clipper toggle`
- wallpaper: `qs -c noctalia-shell ipc call wallpaper toggle`
- lock: `qs -c noctalia-shell ipc call lockScreen lock`
- power menu: `qs -c noctalia-shell ipc call sessionMenu toggle`
- volume: `qs -c noctalia-shell ipc call volume ...`
- media: `qs -c noctalia-shell ipc call media ...`
- brightness: `qs -c noctalia-shell ipc call brightness ...`

The old DMS-only bindings are intentionally documented as not replicated unless
DMS is installed again:

- `Mod+Alt+N`: rename workspace through DMS
- `Mod+Shift+W`: create window rule through DMS

The old DMS full/minimal keybind file switch is recreated locally for IntelliJ
or other applications that need their own `Mod` shortcuts. `Mod+Alt+I` switches
between:

- `~/.config/niri/cfg/keybinds-full.kdl`: the complete shortcut set
- `~/.config/niri/cfg/keybinds-minimal.kdl`: only `Mod+Alt+I` and
  `Mod+Backslash`

The active file included by niri remains `~/.config/niri/cfg/keybinds.kdl`.
The switch is handled by `~/.config/niri/cfg/keybind-mode`, which copies the
selected template, validates the full config, and reloads niri.
The script is Linux/Niri-specific and intentionally no-ops on macOS.

### Shortcut Help File

The visible shortcut summary lives at:

```text
~/.config/niri/cfg/keybinds-riepilogo.txt
```

It is opened by this binding in `~/.config/niri/cfg/keybinds.kdl`:

```kdl
Mod+Backslash allow-inhibiting=false hotkey-overlay-title="Keybinds Summary" {
    spawn "alacritty" "--title" "Niri keybinds" "-e" "less" "/home/birbante/.config/niri/cfg/keybinds-riepilogo.txt";
}
```

Keep `allow-inhibiting=false` on the help binding and keep the same binding in
`keybinds-minimal.kdl` so `Mod+Backslash` still opens the help in IntelliJ mode.

When changing key combinations in `~/.config/niri/cfg/keybinds.kdl`, update
`~/.config/niri/cfg/keybinds-full.kdl` and
`~/.config/niri/cfg/keybinds-riepilogo.txt` in the same change so the full
template and help stay in sync.

Create or refresh the help file by reading `cfg/keybinds.kdl` and grouping the
bindings by purpose. The help is a fixed-width two-column text file: first
column for key/group, second column for action/note, with a maximum of 40
characters per column and 80 characters per line. Keep the IntelliJ mode note
first, then group the main window-management sections before app/session/media
sections:

```text
Tasto / gruppo                          Azione / nota
================================================================================

Modalita IntelliJ
Linee guida
Navigazione
Spostamento / Posizione
Layout / Stato Finestra
Apps / shell
Sessione / Sistema
Audio / Media / Luminosita
Alt-Tab
Screenshot
Non replicati senza DMS
```

The help file is not generated automatically right now; it is a maintained
summary. If automation is added later, keep the generated output concise and
human-readable, and still validate niri after changing `cfg/keybinds.kdl`.

### Current Shortcut Intent

The local keymap is meant to preserve muscle memory from the previous Dank/DMS
configuration while using this system's available components:

- `Mod+A`, `Mod+S`, `Mod+N`, and `Mod+V` call Noctalia panels or plugins.
- `Mod+T` opens `alacritty`, because `kitty` is not installed.
- `Mod+Tab` toggles niri overview.
- `Mod+Alt+I` switches between full and minimal keybind templates for IntelliJ
  keybind passthrough.
- `Mod+Backslash` opens the shortcut help in both full and minimal modes.
- `Mod+Alt+Left/Right` changes column width and `Mod+Alt+J/K` changes window
  height.
- `Alt+Tab`, `Alt+Shift+Tab`, `Alt+A`, and `Alt+Shift+A` are configured through
  `recent-windows` to match the old Alt-Tab workflow.
- Screenshots are on `Print`, `Ctrl+Print`, and `Alt+Print`, with `XF86Launch1`
  alternatives.

## IntelliJ / JetBrains

IntelliJ IDEA is installed through JetBrains Toolbox:

```text
~/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin/idea
```

The desktop launcher is:

```text
~/.local/share/applications/jetbrains-idea-dcb504fb-0d49-41d3-9c0a-ee02df3678b0.desktop
```

On 2026-06-13, IntelliJ started working after this package transaction:

```bash
pacman -S code docker docker-compose gimp inkscape thunderbird libreoffice-fresh libmythes skrooge scrcpy vlc virt-manager
```

The exact minimal dependency was not isolated. The likely fix came from GUI or
desktop-runtime dependencies pulled in by that transaction, especially the
Electron/desktop stack (`code`, `electron42`) or related GUI/runtime libraries
installed alongside Thunderbird, VLC, Qt, KDE Frameworks, and virt-manager.

If IntelliJ exits silently again, first run it from a terminal outside sandbox:

```bash
~/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin/idea
```

Useful logs:

```text
~/.cache/JetBrains/IntelliJIdea2026.1/log/idea.log
```

If the log mentions locked cache databases or `StorageAlreadyInUseException`,
check for an already running IntelliJ process before deleting cache files.

### IntelliJ / JetBrains Limits

Large JetBrains projects need higher inotify and file descriptor limits. The
live system files are:

```text
/etc/sysctl.d/90-jetbrains-idea.conf
/etc/security/limits.d/90-jetbrains-idea.conf
/etc/systemd/user.conf.d/90-jetbrains-idea.conf
```

The configured values are:

```text
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 2048
fs.inotify.max_queued_events = 32768
DefaultLimitNOFILE = 1048576
birbante nofile = 1048576
```

Because normal chezmoi applies target the home directory, these root-owned
files are maintained by the chezmoi source script:

```text
~/.local/share/chezmoi/run_onchange_after_90-jetbrains-idea-limits.sh
```

It uses `sudo` to install the files under `/etc` and reloads the sysctl values.
Verify with:

```bash
sysctl fs.inotify.max_user_watches fs.inotify.max_user_instances fs.inotify.max_queued_events
cat /proc/$(pgrep -n -f 'intellij-idea/bin/idea')/limits | rg 'Max open files'
```

## Noctalia Clipboard History

Noctalia clipboard history needs `cliphist` plus `wl-clipboard`. The live
setting is in `~/.config/noctalia/settings.json`:

```json
"enableClipboardHistory": true
```

Noctalia starts the clipboard watchers only when the shell initializes. After
installing `cliphist` or changing the clipboard history setting, restart the
shell or log out and back in:

```bash
pkill qs
qs -c noctalia-shell &
```

The watcher commands are:

```text
wl-paste --type text --watch cliphist store
wl-paste --type image --watch cliphist store
```

## Noctalia Config

Manage Noctalia settings in chezmoi as configuration, but do not add downloaded
plugin code or runtime data wholesale.

Managed Noctalia settings include:

- `~/.config/noctalia/settings.json`
- `~/.config/noctalia/plugins.json`
- `~/.config/noctalia/colors.json`
- plugin `settings.json` files, for example screen-toolkit and keybind-cheatsheet

Do not manage `~/.config/noctalia/plugins/clipper/pinned.json` by default,
because it can contain clipboard-derived personal data.

### Noctalia Theme Generation

Noctalia's Alacritty template is enabled in
`~/.config/noctalia/settings.json` under `templates.activeTemplates` with the
`alacritty` id. The generated terminal theme lives at:

```text
~/.config/alacritty/themes/noctalia.toml
```

`~/.config/alacritty/alacritty.toml` imports that generated theme. Keep color
palette sections such as `[colors.primary]`, `[colors.normal]`, and
`[colors.bright]` out of the main Alacritty config unless deliberately
overriding Noctalia, because they can mask the generated theme.

## Alacritty / Tmux

Alacritty uses `FiraCode Nerd Font Mono` so terminal glyphs can render when
needed. FiraCode Nerd Font is managed from the upstream Nerd Fonts download
page, not by storing font binaries in chezmoi. The chezmoi source script
`run_onchange_after_80-firacode-nerd-font.sh` downloads the official FiraCode
zip from `https://www.nerdfonts.com/font-downloads` /
`https://github.com/ryanoasis/nerd-fonts` and installs it under:

```text
Linux: ~/.local/share/fonts/nerd-fonts/FiraCode
macOS: ~/Library/Fonts/NerdFonts/FiraCode
```

Refresh it with `chezmoi apply` after changing the version in the script. The
script refreshes `fc-cache` on Linux when available. The Arch package
`ttf-firacode-nerd` provides the same family and can remain installed as a
system fallback.

Install `ttf-nerd-fonts-symbols` and `ttf-nerd-fonts-symbols-mono` as Nerd Font
symbol fallbacks. They provide `Symbols Nerd Font` and `Symbols Nerd Font Mono`
for glyphs that may not be covered or selected correctly by the primary terminal
font.

Starship configuration lives in `~/.config/starship.toml`. The active prompt is
an LCARS-inspired glyph-heavy multi-line prompt using the Classic palette from
TheLCARS.com: orange, moonlit-violet, blue, ice, sunglow, red, gray, and
space-white. Its structure is: exit-code header, system identity row,
dedicated `LINK` row for active IPv4 interfaces, connection row,
optional session-context rows, location/context row, optional folder-context rows,
telemetry row, and a command row that shows only the `CMD` label on success,
or `RED ALERT DIAG`, `NAV`, `REPL`, or `VIS` when state needs to be visible.
The header shows the previous command's exit code as `EXIT 0` on success or
`EXIT <code>` on failure in a single-color capsule: green for success, red for
failure, padded so the first row is 80 columns long. Each primary
prompt row starts with the same full-block left rail, green after `EXIT 0` and
red after a non-zero exit. The `EXIT` header starts with an additional full
block instead of a semicircle, while the other primary rows continue with an
opening semicircle glyph, an 8-character label segment
(`SYS     `, `NODE    `, `CONN    `, `LINK    `, `LOC     `,
`GIT     `, `NODEJS  `, `PYTHON  `, `RUST    `, `GO      `, `DOCKER  `,
`CONDA   `, `KUBE    `, `KCFG    `, `CHRONO  `, or `CMD     `), a triangular
separator, and then plain foreground-only content without a background. Multiple label/value segments may
appear on the same row, as in the system identity row. The `CONN` row is
dedicated and sits after `LINK`; it shows the user plus `LOCAL` or
`SSH <client-ip>` based on `SSH_CONNECTION`, `SSH_CLIENT`, or `SSH_TTY`. The
`SYS` row shows both OS icon and OS name. Session-context rows such as
`CONDA`, `DOCKER`, `KUBE`, and `KCFG` appear immediately after `CONN` as primary
rows because they are not subordinate to the current directory; they are
generated by `~/.local/bin/starship-session-context`. Folder-context rows such
as `GIT` and project runtimes appear immediately after `LOC` only when their
Starship modules are active, indented by two plain spaces after the left rail so
they read as subordinate location context; directories without such context do
not leave blank rows. Both context helpers delegate module detection/rendering
to `starship module` and add the dynamic left rail. This
dynamic rail depends on
`STARSHIP_CMD_STATUS` being exported by `~/.bashrc.d/95-starship-prompt.sh`
before Starship is initialised by bash. The `LINK`
row is shown both locally and over SSH. The telemetry row uses a human-readable
`CHRONO YYYY-MM-DD HH:MM` segment rather than a numeric stardate.
Bright LCARS panels such as orange, yellow, aqua, blue, purple, and red should
use `color_bg_console` text; reserve `color_fg0` for genuinely dark panels such
as command duration. A timestamped backup of the original restored prompt is
kept at:

```text
~/.config/starship.toml.backup-20260707-233053
```

Avoid emoji fallback glyphs in this prompt; use only known Nerd Font private-use
symbols and test inside Alacritty and tmux after changes.

The `LINK` row is a Starship custom module backed by:

```text
~/.local/bin/starship-link-ips
```

It lists active global IPv4 addresses for physical interfaces only as
`interface=address`, for example `wlan0=10.11.12.103` when run with `--plain`.
Virtual interfaces such as Docker bridges, libvirt bridges, veth, tun/tap,
WireGuard, and macOS `utun` are intentionally hidden. For the prompt it emits
ANSI-formatted LCARS segments so each interface name becomes its own
8-character label followed by the IP address as plain foreground text. Starship
calls it through `$HOME/.local/bin/starship-link-ips` so the same config works
under Linux and macOS home directories. If no physical link is detected, the
prompt shows `NO PHYSICAL LINK` instead of leaving a blank row. Keep the script
small and shell-compatible because Starship runs it on every prompt draw. It
uses `ip` and `/sys/class/net` on Linux, and falls back to parsing `ifconfig -a`
plus `networksetup` or conservative interface-name heuristics on macOS/BSD. The
script searches `/usr/bin`, `/bin`, `/usr/sbin`, and `/sbin` explicitly because
Starship may run with a reduced `PATH` on macOS.

The prompt layout uses independent rounded capsule segments rather than one
continuous powerline chain. Keep optional modules such as git, language
runtimes, Docker, Kubernetes, command duration, and status self-contained with
their own opening and closing glyphs so disabled or inactive modules do not
leave empty separators behind.

ble.sh provides Bash autosuggestions, auto-complete while typing, and syntax
highlighting. Keep the managed local copy at `~/.local/share/blesh` on
`0.4.0-devel3-2` or newer, because the older `0.3.4` copy reparses `PS1` and
downgrades Starship's truecolor prompt escapes from 24-bit colors to indexed
ANSI colors. The chezmoi source script
`run_onchange_after_70-blesh.sh` downloads the upstream release from
`https://github.com/akinomyoga/ble.sh` and installs it there.

The Bash startup order for ble.sh is deliberate:

- `~/.bashrc.d/90-blesh.sh` sources ble.sh with `--attach=none` and sets
  `bleopt term_true_colors=semicolon` when the option exists.
- `~/.bashrc.d/95-starship-prompt.sh` initialises Starship.
- `~/.bashrc.d/99-blesh-attach.sh` runs `ble-attach` after Starship so ble.sh
  sees the final prompt and preserves the LCARS truecolor rendering.

Existing tmux panes keep already-rendered prompt text in their visible buffer.
After changing Starship symbols or terminal fonts, press Enter in old panes to
draw a fresh prompt and use `Ctrl-L` if the stale prompt remains visible.

## Bash Completion

Bash completion setup lives in `~/.bashrc.d/20-completion.sh`. Keep standard
`bash-completion` as the owner of command-specific completions such as `git`,
`paru`, and package manager commands. Load fzf key bindings for `Ctrl-r`,
`Ctrl-t`, and `Alt-c`, but do not source fzf's broad `completion.bash` by
default because it can replace command-specific completions with the generic
`_fzf_path_completion` handler.

Tmux auto-start is handled by `~/.bashrc.d/30-tmux.sh`, not by Alacritty.
Alacritty launches the normal user shell, then the shell initialisation decides
whether to enter tmux. Local interactive terminal shells run `tmux new-session`,
so each local terminal gets an independent tmux session.

Interactive SSH logins attach to one persistent tmux session named `ssh` with
`tmux new-session -A -s ssh`. The script only runs for interactive terminal
shells, skips when already inside tmux, and can be bypassed globally with:

```bash
NO_AUTO_TMUX=1 bash
```

For an SSH one-off bypass, use:

```bash
ssh -t <host> 'NO_SSH_TMUX=1 bash -l'
```

This keeps local terminals independent while remote SSH logins always return to
the same session.

The tmux configuration lives in `~/.tmux.conf`. It keeps
`default-terminal` on `tmux-256color` and enables RGB/truecolor for
`xterm-256color`, `alacritty`, and `xterm-kitty` clients. If Starship colors look
flattened or indexed again, check `tmux capture-pane -e` for `38;2`/`48;2`
escapes and reload with:

```bash
tmux source-file ~/.tmux.conf
```

Some shells may start with `TERM=xterm-kitty` even though this system does not
install the `kitty` or `kitty-terminfo` Arch packages. The ncurses database does
provide a `kitty` entry, so a local `xterm-kitty` alias is maintained at:

```text
~/.local/share/terminfo-src/xterm-kitty.terminfo
```

Chezmoi recompiles it into `~/.terminfo` through:

```text
~/.local/share/chezmoi/run_onchange_after_75-xterm-kitty-terminfo.sh
```

Verify with `infocmp xterm-kitty` and `TERM=xterm-kitty tput colors`.

## Libvirt Windows VM / Docker Networking

The Windows 11 libvirt VM is defined in the system libvirt instance, not the
user session:

```bash
virsh -c qemu:///system list --all
```

Current network layout:

```text
VM:        win11
Network:   default
Mode:      libvirt NAT
Bridge:    virbr0
Host IP:   192.168.122.1/24
DHCP:      192.168.122.2 - 192.168.122.254
VM IP:     192.168.122.100/24
Hostname:  JeegRobot
MAC:       52:54:00:dd:99:94
Model:     virtio
```

`win11` has a persistent DHCP reservation in the libvirt `default` network:

```xml
<host mac='52:54:00:dd:99:94' name='JeegRobot' ip='192.168.122.100'/>
```

If the VM still has an old lease such as `192.168.122.200`, renew DHCP inside
Windows or reboot the VM. The reservation is applied by libvirt when the guest
requests a new lease.

For RDP from the host, connect to:

```text
192.168.122.100:3389
```

RDP must still be enabled inside Windows and allowed by the Windows firewall.
Because the VM uses libvirt NAT, `192.168.122.100` is directly reachable from
the host, but not automatically from other devices on the Wi-Fi LAN.

### Windows VM CPU Limit

`win11` keeps 2 vCPUs visible to Windows, but libvirt limits the VM to about 1
CPU core total with:

```xml
<cputune>
  <global_period>100000</global_period>
  <global_quota>100000</global_quota>
</cputune>
```

This was applied live and persistently with:

```bash
virsh -c qemu:///system schedinfo win11 --set global_period=100000 --set global_quota=100000 --live --config
```

Use `global_quota=-1` to remove the limit, or set a higher quota to allow more
CPU time. With `global_period=100000`, `global_quota=100000` means roughly 1 CPU
core total, regardless of the number of vCPUs exposed to the guest.

From Windows, host services exposed on the libvirt NAT address should be reached
through `192.168.122.1`, for example `http://192.168.122.1:21090`.

Docker publishes the local development services on the host, including ports
`21080`, `21090`, and `21091`. If Windows can ping `192.168.122.1` but cannot
open those ports, check UFW first. A UFW forward rule for `192.168.122.0/24` is
not enough for this case, because the VM is connecting directly to the host, so
the traffic hits the input chain on `virbr0`.

Allow only the libvirt NAT subnet to reach those development ports:

```bash
sudo ufw allow in on virbr0 from 192.168.122.0/24 to 192.168.122.1 port 21080 proto tcp
sudo ufw allow in on virbr0 from 192.168.122.0/24 to 192.168.122.1 port 21090 proto tcp
sudo ufw allow in on virbr0 from 192.168.122.0/24 to 192.168.122.1 port 21091 proto tcp
```

Useful checks:

```bash
virsh -c qemu:///system domiflist win11
virsh -c qemu:///system net-dhcp-leases default
virsh -c qemu:///system net-dumpxml default
virsh -c qemu:///system schedinfo win11
ss -ltnp
curl -I http://192.168.122.1:21090
journalctl -b --no-pager | rg 'UFW BLOCK|192\.168\.122|21090|21091|21080|3389'
```
