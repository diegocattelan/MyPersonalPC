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
~/.local/share/fonts/nerd-fonts/FiraCode
```

Refresh it with `chezmoi apply` after changing the version in the script. The
Arch package `ttf-firacode-nerd` provides the same family and can remain
installed as a system fallback.

Starship configuration lives in `~/.config/starship.toml`. The active prompt is
intentionally simple and ASCII-only to avoid terminal/font rendering problems.
The previous glyph-heavy Starship config is backed up at:

```text
~/.config/starship.toml.backup-20260707-233053
```

If a glyph-heavy prompt is restored later, avoid emoji fallback glyphs; use only
known Nerd Font private-use symbols and test inside Alacritty and tmux.

Existing tmux panes keep already-rendered prompt text in their visible buffer.
After changing Starship symbols or terminal fonts, press Enter in old panes to
draw a fresh prompt and use `Ctrl-L` if the stale prompt remains visible.

Alacritty starts `tmux new-session` by default through
`~/.config/alacritty/alacritty.toml`. This keeps normal terminal launches inside
tmux while giving each Alacritty window an independent tmux session. Do not use
`tmux new-session -A -s main` here unless the intended behavior is to show the
same tmux session in every terminal. Alacritty invocations with an explicit
command, for example `alacritty -e less ...`, still run that command instead of
the default shell.

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
