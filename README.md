# Personal dotfiles

My terminal setup for Linux, managed with [GNU Stow](https://www.gnu.org/software/stow/).
The core configuration covers Neovim, tmux, Zsh, Starship, and tealdeer.

## Fresh Linux installation

Automatic package installation supports modern **Ubuntu, Debian, Raspberry Pi OS,
and compatible apt-based distributions**. There is no Ubuntu 22/24/26 version
whitelist. Full tool setup requires 64-bit **amd64 or arm64 userland**.
This setup was developed on Ubuntu 22.04.5. It recreates the core terminal workflow,
not a complete machine image or an exact snapshot of installed versions.

```bash
git clone https://github.com/Magdiel3/dotfiles.git
cd dotfiles
./install.sh --dry-run
./install.sh
```

Run it as your normal user, with sudo access. It requests `sudo` only for distro
package installation.
The preview does not download anything, install packages, or change files.

The installer checks distro packages through `dpkg-query` and only asks apt to
install missing packages. Separately, it checks CLI tools already available on
`PATH`. Compatible installations are retained, whether managed by apt, Snap, Bob,
Cargo, an official installer, or another tool manager.

An existing version that is too old causes a clear error instead of silently
replacing your chosen installation. Applying dotfiles does not implicitly upgrade
existing CLI tools. A tool installed outside `PATH` cannot be detected this way.
The package checks use apt's package records, not just executable names.

When dependencies are missing, the installer supplies:

| Source | Tools |
| --- | --- |
| Distro packages | Stow, tmux, Zsh, Git, curl, Python, C build tools, ripgrep, fd, bat, clipboard tools, and desktop keyring support |
| Official upstream releases | Latest stable Neovim, fzf, Starship, GitHub CLI, tealdeer, and standalone Tree-sitter CLI |
| Node.js distribution | Latest Node.js 22 release, with npm |
| User-local npm packages | MCP Hub |
| Plugin managers | Neovim plugins and configured language tools, plus tmux plugins through TPM |

Older distro Neovim, fzf, and Node.js packages can be too old for these plugins.
Upstream binaries go under `~/.local/share/dotfiles/tools`, with links in
`~/.local/bin`. Their SHA-256 digests are checked before extraction.
MCP Hub installs under `~/.local`, without `sudo npm`. Tree-sitter CLI uses the
standalone upstream binary, not its npm wrapper.
Downloads need access to GitHub, Node.js, and npm.

| Dependency | Minimum used by this setup |
| --- | --- |
| Neovim | 0.12.0 |
| tmux | 3.2 |
| fzf | 0.60.0 |
| Node.js | 22.0.0, with npm and npx |
| npm | 8.0.0 |
| Tree-sitter CLI | 0.26.1 |

The core Stow packages and optional Hunk configuration are linked. Desktop terminal configs are optional.
The installer uses `--no-folding` so configuration directories remain real
directories rather than links to whole repository folders.

**Existing configuration files are not overwritten or adopted.** Stow reports
conflicts and stops. Back up or move the conflicting files yourself, then rerun.
Existing unrelated files in a required `~/.local/bin` destination also cause
installation to stop. Compatible executables already on `PATH` are left alone.
Installation is not transactional. If a later step fails, packages and tools
already installed remain in place.

### Raspberry Pi 5

For a Pi 5 running **64-bit Raspberry Pi OS**, use the normal installer commands
above. Bookworm/Trixie-based systems are the intended baseline. Architecture
detection uses `dpkg --print-architecture`, not just the CPU or kernel, so a
64-bit CPU running 32-bit userland is not mistaken for an ARM64 installation.

There is no longer a Raspberry Pi OS rejection based on the distro name.
However, this installer has not been exercised on a physical Pi. Parser compilation
can be slow, and upstream binaries still depend on compatible system libraries.
Very old distributions may need source builds or tool managers instead.

On **32-bit Raspberry Pi OS**, the automatic binary-download path is unavailable.
You can still install base packages, obtain compatible tools yourself, and link
the same configurations:

```bash
./install.sh --packages-only
# Install compatible Neovim, Node.js, fzf, and other tools for your architecture.
./install.sh --link-only
```

### Choose your own tool installers

To install only distro dependencies, without downloading tools, linking configs,
or starting plugins:

```bash
./install.sh --packages-only
```

Then install the tools with your preferred methods and run `./install.sh --link-only`.
The full installer also keeps compatible tools that you install this way first.

| Tool | Alternative installation method |
| --- | --- |
| Neovim | [Bob version manager](https://github.com/MordechaiHadad/bob), a compatible distro package, Snap, or [official Neovim releases](https://neovim.io/doc/install/) |
| Starship | [Official installer or package-manager instructions](https://starship.rs/guide/) |
| GitHub CLI | [Official signed apt/RPM repositories and other installation methods](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) |
| fzf | [Official releases, Git installation, or distro packages](https://github.com/junegunn/fzf#installation) |
| Tree-sitter CLI | [Standalone release or Cargo installation](https://github.com/tree-sitter/tree-sitter/tree/master/crates/cli) |

The automatic installer downloads official release artifacts rather than executing
upstream shell installers or adding third-party apt repositories.

If you already use Bob, select a compatible Neovim version and expose its shim
before running the installer:

```bash
bob use stable
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
./install.sh --dry-run
```

Keep that PATH setting in `~/.zshrc_local` if it is part of your normal setup.
The installer does not install Bob, change its selected version, or remove other
Neovim installations.

### Other distributions and manual adoption

Package manifests are provided separately from tool installation:

| File | Package ecosystem |
| --- | --- |
| `packages/apt.txt` | Ubuntu, Debian, Raspberry Pi OS, and compatible derivatives |
| `packages/dnf.txt` | Fedora base dependencies for manual installation |
| `packages/pacman.txt` | Arch Linux base dependencies for manual installation |

Automatic package installation currently handles apt-based systems only. The
Fedora and Arch manifests are manual starting points, not claims of verified full
installer support. Review package availability on your distro.

For example:

```bash
# Fedora
grep -vE '^(#|$)' packages/dnf.txt | xargs -r sudo dnf install

# Arch Linux. This performs the normal full system upgrade too.
grep -vE '^(#|$)' packages/pacman.txt | xargs -r sudo pacman -Syu --needed
```

Install compatible versions of the tools in the minimum-version table through
your package or version managers, then apply the dotfiles:

```bash
./install.sh --link-only --dry-run
./install.sh --link-only
```

The link-only operation needs Bash and GNU Stow. It bypasses distro, architecture,
and tool-version checks and does not install tools, download plugins, or run them.
You are responsible for runtime compatibility. These configs currently expect
the standard `~/.config` location.

To install tools and configs but leave plugin installation manual:

```bash
./install.sh --skip-plugins
```

## Finish setup

Choose Zsh as your login shell, then log out and back in:

```bash
chsh -s "$(command -v zsh)"
```

Configure a [Nerd Font](https://www.nerdfonts.com/) in your terminal emulator.
For SSH sessions, the font belongs on the client machine, not the remote server.
The installer does not change terminal settings or install desktop applications.

GitHub authentication remains manual:

```bash
gh auth login --hostname github.com
gh auth status --hostname github.com
```

Inside Neovim, run `:Copilot setup` to authenticate the Copilot integration.
An eligible Copilot account is required for AI features. Never copy tokens or
authentication caches into this repository.

Open Neovim and run `:checkhealth`. Tree-sitter parsers install through the
configuration, and Mason manages Lua, Python, Ruff, Rust Analyzer, and StyLua.
Project runtimes such as Rust/Cargo or Go are separate installations.
If plugin setup was skipped, run `:Lazy sync` and `:MasonToolsInstallSync`.

For manual tmux plugin setup:

```bash
bash ~/.config/tmux/plugins/install_tpm.sh
tmux
```

Inside tmux, press `Ctrl+b` then `I` to install plugins.
The installer uses a temporary, isolated tmux server for this step and does not
reload or stop existing sessions.

### Private settings

Put credentials, custom certificate paths, and workstation-specific exports in
`~/.zshrc_local`. Zsh loads it when present.

```bash
touch ~/.zshrc_local
chmod 600 ~/.zshrc_local
```

Do not commit that file. Corporate certificates, SSH keys, proxy settings,
GitHub login caches, and private development tools are not provisioned.
OpenCode, Hunk, Graphite, Rust, and Go are optional. Their shell hooks do not
imply that the installer installs them.

### Optional Hunk setup

Install [Hunk](https://github.com/modem-dev/hunk) separately, then install the
commit review extension:

```bash
hunk extension install sadick254/hunk-commit-log@6a08a018bac73924bbc6c2e29008da2160739fcf
```

The extension checkout stays outside this repository. The local Hunk extension
starts its commit list and message panes hidden. In `hunk show`, use `h` for
the commit list, `i` for the message, `I` to expand it, `p` for the
previous commit, and `P` for the next. Search keeps `n` for the next match.

### Optional Copilot usage recording

The tmux dashboard can fetch usage through authenticated `gh`. Its GitHub endpoint
is undocumented and may change. A failed request falls back to manual entry.

After authenticating, enable periodic recording if wanted:

```bash
systemctl --user daemon-reload
systemctl --user enable --now copilot-usage.timer
systemctl --user list-timers copilot-usage.timer
```

The timer records every two hours and at 23:55. It starts with your user manager,
normally when you log in, and catches up missed runs.
Usage samples stay in `~/.copilot_usage`, outside the repository.

To disable it:

```bash
systemctl --user disable --now copilot-usage.timer
```

### Optional laptop battery display

For a Windows laptop connecting over SSH, use
`tmux/.config/tmux/client-scripts/push_battery.ps1`.
Set its SSH destination and follow the startup instructions in the script.
Without a recent client reading, tmux shows an unknown battery indicator.

### Optional Workmux agent dashboard

Install [Workmux v0.1.281](https://github.com/raine/workmux/releases/tag/v0.1.281)
separately using the release binary for your architecture. Verify its SHA-256
digest before extraction and place `workmux` on `PATH`.

The optional Stow package includes the dashboard configuration and Copilot CLI
personal hooks. It is not linked by the core installer:

```bash
stow --no-folding --target="$HOME" workmux
tmux source-file ~/.config/tmux/tmux.conf
```

No sidebar is enabled. The dashboard shows registered agent panes across all
sessions, including multiple Copilot panes sharing one worktree. Sessionx remains
the picker for all tmux sessions. Workmux defaults to session mode for future
worktrees and leaves the existing window names and status-bar styling intact.

Start a new Copilot session, or use `/restart` in an existing one, to load the
hooks. They report working, waiting for permission or input, and turn completion.
Avoid restarting an agent while it is working. Select a dashboard row and press
`Enter` to visit its pane, `p` to preview it, or `i` to forward input.

To list already running Copilot panes without restarting them, run this from a
shell in tmux, replacing `%32` with the target pane ID:

```bash
tmux list-panes -a -F '#S:#I.#P #{pane_id} #{pane_current_command}'
TMUX_PANE=%32 workmux register-agent
```

Manual registration makes the pane visible but does not load hooks into its
running Copilot process. Automatic status updates require a new or restarted
Copilot session. To unlink the configuration and hooks:

```bash
stow --delete --target="$HOME" workmux
```

## Useful shortcuts

Neovim uses `Space` as the leader key.

| Tool | Shortcut | Action |
| --- | --- | --- |
| Neovim | `<leader>e` / `<leader>bf` | Toggle file / open-buffer sidebar |
| Neovim | `<leader>ff` / `<leader>fg` | Find files / search project text |
| Neovim | `<leader>cc` / `<leader>ci` | Toggle AI chat / inline interaction |
| Neovim | `<leader>gc` | Browse a commit in Diffview |
| Neovim | `<leader>gg` / `<leader>gG` | Copy a current-commit / selected-branch line link |
| tmux | `Ctrl+b`, then `o` | Open the session picker |
| tmux | `Ctrl+b`, then `T` | Toggle the persistent floating terminal |
| tmux | `Ctrl+b`, then `a` / `A` | Cycle panes while preserving zoom |
| tmux | `Ctrl+b`, then `H` | Show GitHub connectivity and latency |
| tmux | `Ctrl+b`, then `g` / `G` | Show Copilot usage / daily history |
| tmux | `Ctrl+b`, then `W` | Open the Workmux agent dashboard |
| tmux | `Ctrl+b`, then `Ctrl+w` | Show agents in the current tmux session |
| tmux | `Ctrl+b`, then `Ctrl+l` | Jump to a waiting or completed agent |

The session picker uses a personal
[tmux-sessionx fork](https://github.com/Magdiel3/tmux-sessionx/tree/show-main-window-branch)
to omit the repository's default branch from session labels.

## Manual Stow management

From the repository root:

```bash
stow --no-folding --target="$HOME" nvim tmux zsh starship tldr hunk
stow --delete --target="$HOME" nvim tmux zsh starship tldr hunk
```

`terminator` is an optional Linux desktop terminal configuration.
The `westerm` directory contains a Windows WezTerm configuration and is not
included in the core installer.

`minimal.lua` and `.repro/` are local CodeCompanion debugging artifacts, not part
of the normal setup. A local `AGENTS.md` guides coding assistants and is not needed
to load any configuration.
