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

The old DMS full/minimal keybind file switch is not recreated. Use niri's native
shortcut inhibitor instead: `Mod+Alt+I` toggles
`toggle-keyboard-shortcuts-inhibit` for IntelliJ or other applications that need
their own `Mod` shortcuts.

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

Keep `allow-inhibiting=false` on the help binding so `Mod+Backslash` still opens
the help while shortcut inhibition is active.

When changing key combinations in `~/.config/niri/cfg/keybinds.kdl`, update
`~/.config/niri/cfg/keybinds-riepilogo.txt` in the same change so the help stays
in sync.

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
- `Mod+Alt+I` toggles niri shortcut inhibition for IntelliJ keybind passthrough.
- `Mod+Backslash` opens the shortcut help even when shortcut inhibition is active.
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
