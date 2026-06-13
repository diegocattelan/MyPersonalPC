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
- `Mod+Alt+I`: switch between DMS full/minimal keybind modes

### Shortcut Help File

The visible shortcut summary lives at:

```text
~/.config/niri/cfg/keybinds-riepilogo.txt
```

It is opened by this binding in `~/.config/niri/cfg/keybinds.kdl`:

```kdl
Mod+Backslash hotkey-overlay-title="Keybinds Summary" {
    spawn "alacritty" "--title" "Niri keybinds" "-e" "less" "/home/birbante/.config/niri/cfg/keybinds-riepilogo.txt";
}
```

When changing key combinations in `~/.config/niri/cfg/keybinds.kdl`, update
`~/.config/niri/cfg/keybinds-riepilogo.txt` in the same change so the help stays
in sync.

Create or refresh the help file by reading `cfg/keybinds.kdl` and grouping the
bindings by purpose. Keep these section names so the document stays easy to scan:

```text
Niri keybinds
=============

Apps / shell
Sessione / Sistema
Audio / Media / Luminosita
Navigazione
Alt-Tab
Spostamento / Posizione
Layout / Stato Finestra
Screenshot
Non replicati senza DMS
```

The help file is not generated automatically right now; it is a maintained
summary. If automation is added later, keep the generated output concise and
human-readable, and still validate niri after changing `cfg/keybinds.kdl`.

### Current Shortcut Intent

The local keymap is meant to preserve muscle memory from the previous Dank/DMS
configuration while using this system's available components:

- `Mod+A`, `Mod+S`, `Mod+N`, `Mod+V`, `Mod+Y` call Noctalia panels or plugins.
- `Mod+T` opens `alacritty`, because `kitty` is not installed.
- `Mod+D` and `Mod+Tab` both toggle niri overview, matching the old behavior.
- `Alt+Tab`, `Alt+Shift+Tab`, `Alt+A`, and `Alt+Shift+A` are configured through
  `recent-windows` to match the old Alt-Tab workflow.
- Screenshots are on `Print`, `Ctrl+Print`, and `Alt+Print`, with `XF86Launch1`
  alternatives.
