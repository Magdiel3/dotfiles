#!/bin/bash

# Install the core terminal setup on modern apt-based Linux distributions.
# Usage: ./install.sh [--dry-run] [--link-only | --packages-only] [--skip-plugins]
# Example: ./install.sh --dry-run

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$HOME/.local/share/dotfiles/tools"
BIN_DIR="$HOME/.local/bin"
COMPONENTS=(nvim tmux zsh starship tldr)
PACKAGES=()
while IFS= read -r package; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    PACKAGES+=("$package")
done < "$REPO_DIR/packages/apt.txt"
declare -A install_tool
dry_run=false
link_only=false
packages_only=false
skip_plugins=false
temp_dir=""
socket=""

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

usage() {
    printf '%s\n' \
        'Usage: ./install.sh [--dry-run] [--link-only | --packages-only] [--skip-plugins]' \
        '  --dry-run       Preview installation and check Stow conflicts.' \
        '  --link-only     Link configs without installing tools or plugins.' \
        '  --packages-only Install missing distro packages without downloading tools or linking configs.' \
        '  --skip-plugins  Install tools and configs, but leave plugin setup manual.' \
        '  --help          Show this help.'
}

for argument in "$@"; do
    case "$argument" in
        --dry-run) dry_run=true ;;
        --link-only) link_only=true ;;
        --packages-only) packages_only=true ;;
        --skip-plugins) skip_plugins=true ;;
        --help|-h) usage; exit 0 ;;
        *) die "Unknown argument: $argument" ;;
    esac
done
$link_only && $packages_only && die "Choose either --link-only or --packages-only."

cleanup() {
    if [[ -n "$socket" ]]; then
        tmux -S "$socket" kill-server >/dev/null 2>&1 || true
    fi
    if [[ -n "$temp_dir" ]]; then
        rm -rf -- "$temp_dir"
    fi
}
trap cleanup EXIT

[[ -d "$HOME" ]] || die "HOME must point to an existing directory."
if ! $packages_only; then
    [[ "${XDG_CONFIG_HOME:-$HOME/.config}" == "$HOME/.config" ]] || \
        die "These configs currently require XDG_CONFIG_HOME=$HOME/.config."
fi

if ! $link_only; then
    # shellcheck source=/etc/os-release
    source /etc/os-release
    case " $ID ${ID_LIKE:-} " in
        *" ubuntu "*|*" debian "*|*" raspbian "*|*" raspios "*) ;;
        *) die "Automatic package installation requires an apt-based distro. See packages/ and use --link-only." ;;
    esac
    command -v apt-get >/dev/null 2>&1 && command -v dpkg-query >/dev/null 2>&1 || \
        die "apt-get and dpkg-query are required."
    [[ -z "${SUDO_USER:-}" ]] || die "Run this script as your normal user, not with sudo."
    if ! $packages_only; then
        case "$(dpkg --print-architecture)" in
            amd64) arch=x86_64; node_arch=x64; go_arch=amd64 ;;
            arm64) arch=aarch64; node_arch=arm64; go_arch=arm64 ;;
            *) die "Full setup requires 64-bit amd64 or arm64 userland. Use --packages-only and --link-only on 32-bit systems." ;;
        esac
    fi
fi

stow_configs() {
    stow --dir="$REPO_DIR" --target="$HOME" --no-folding \
        --ignore='(\.backup|\.modified|\.bak)$' --ignore='(^|/)data\.txt$' \
        "$@" "${COMPONENTS[@]}"
}

if ! $packages_only; then
    if command -v stow >/dev/null 2>&1; then
        stow_configs --simulate
    elif $link_only; then
        die "Install GNU Stow before using --link-only."
    else
        printf '%s\n' 'Stow is not installed yet. Configuration conflicts will be checked after package installation.'
    fi
fi

missing_packages=()
if ! $link_only; then
    for package in "${PACKAGES[@]}"; do
        if [[ "$(dpkg-query --show --showformat='${Status}' "$package" 2>/dev/null || true)" != 'install ok installed' ]]; then
            missing_packages+=("$package")
        fi
    done
fi

check_version() {
    local name="$1" minimum="$2" output version
    output="$("$name" --version 2>/dev/null)" || die "Cannot check $name. Fix its installation before continuing."
    [[ "$output" =~ ([0-9]+\.[0-9]+(\.[0-9]+)?) ]] || die "Cannot parse $name version."
    version="${BASH_REMATCH[1]}"
    [[ "$(printf '%s\n' "$minimum" "$version" | sort -V | head -1)" == "$minimum" ]] || \
        die "$name $version is too old. Upgrade it to at least $minimum using your existing package/version manager."
}

check_binary_slot() {
    local name="$1" path="$BIN_DIR/$1"
    if [[ -e "$path" || -L "$path" ]]; then
        [[ -L "$path" && "$(readlink -- "$path")" == "$TOOLS_DIR/"* ]] || \
            die "Refusing to replace $path. Resolve it manually or use --link-only."
    fi
}

plan_tool() {
    local name="$1" minimum="${2:-}"
    if command -v "$name" >/dev/null 2>&1; then
        [[ -z "$minimum" ]] || check_version "$name" "$minimum"
        install_tool["$name"]=false
        printf 'Keep %s: %s\n' "$name" "$(command -v "$name")"
    else
        check_binary_slot "$name"
        install_tool["$name"]=true
        printf 'Install missing tool: %s\n' "$name"
    fi
}

if ! $link_only && ! $packages_only; then
    plan_tool nvim 0.12.0
    plan_tool fzf 0.60.0
    plan_tool starship
    plan_tool gh
    plan_tool tldr
    plan_tool node 22.0.0
    plan_tool tree-sitter 0.26.1
    if ${install_tool[node]}; then
        check_binary_slot npm
        check_binary_slot npx
    else
        command -v npm >/dev/null 2>&1 && command -v npx >/dev/null 2>&1 || \
            die "Install npm and npx through your existing Node.js manager."
        check_version npm 8.0.0
    fi
fi

if $dry_run; then
    if ! $link_only; then
        printf 'Missing distro packages: %s\n' "${missing_packages[*]:-none}"
        if ! $packages_only; then
            printf '%s\n' 'Install MCP Hub through user-local npm only if mcp-hub is missing.'
        fi
    fi
    if ! $packages_only; then
        printf 'Stow components: %s\n' "${COMPONENTS[*]}"
    fi
    if ! $link_only && ! $packages_only && ! $skip_plugins; then
        printf '%s\n' 'Bootstrap Neovim and tmux plugins using an isolated tmux server.'
    fi
    printf '%s\n' 'No files or packages were changed.'
    exit 0
fi

if $link_only; then
    stow_configs --stow
    printf '%s\n' 'Configurations linked. Tools and plugins were not installed.'
    exit 0
fi

if (( ${#missing_packages[@]} )); then
    sudo apt-get update
    sudo apt-get install --yes "${missing_packages[@]}"
else
    printf '%s\n' 'All distro packages are already installed.'
fi
if $packages_only; then
    printf '%s\n' 'Distro packages are ready. Tools, configurations, and plugins were not changed.'
    exit 0
fi
check_version tmux 3.2
stow_configs --simulate
mkdir -p -- "$BIN_DIR" "$TOOLS_DIR"
export PATH="$PATH:$BIN_DIR"
temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-install.XXXXXX")"

download() {
    curl --fail --location --silent --show-error --retry 3 \
        --connect-timeout 10 --max-time 180 --output "$2" "$1"
}

release_asset() {
    local repo="$1" pattern="$2" metadata
    download "https://api.github.com/repos/$repo/releases/latest" "$temp_dir/release.json"
    metadata="$(python3 - "$temp_dir/release.json" "$pattern" <<'PY'
import json
import re
import sys

with open(sys.argv[1]) as source:
    release = json.load(source)
assets = [a for a in release["assets"] if re.fullmatch(sys.argv[2], a["name"])]
if len(assets) != 1:
    sys.exit("Expected exactly one matching release asset")
asset = assets[0]
digest = asset.get("digest", "")
if not re.fullmatch(r"sha256:[0-9a-f]{64}", digest):
    sys.exit("Upstream did not provide a SHA-256 digest")
tag = release["tag_name"]
if not re.fullmatch(r"[A-Za-z0-9._-]+", tag):
    sys.exit("Unsupported release tag")
print(tag)
print(asset["browser_download_url"])
print(digest[7:])
PY
)"
    local -a values
    mapfile -t values <<< "$metadata"
    RELEASE_TAG="${values[0]}"
    RELEASE_FILE="$temp_dir/asset"
    download "${values[1]}" "$RELEASE_FILE"
    printf '%s  %s\n' "${values[2]}" "$RELEASE_FILE" | sha256sum --check --status
    printf 'Downloaded %s %s\n' "$repo" "$RELEASE_TAG"
}

install_archive() {
    local name="$1" strip="$2"
    TOOL_PATH="$TOOLS_DIR/$name-$RELEASE_TAG"
    mkdir -p -- "$TOOL_PATH"
    tar --extract --file="$RELEASE_FILE" --directory="$TOOL_PATH" --strip-components="$strip"
}

link_binary() {
    [[ -x "$2" ]] || die "Missing executable: $2"
    ln --symbolic --force --no-dereference -- "$2" "$BIN_DIR/$1"
}

if [[ "$arch" == x86_64 ]]; then
    nvim_arch=x86_64
else
    nvim_arch=arm64
fi
if ${install_tool[nvim]}; then
    release_asset neovim/neovim "nvim-linux-$nvim_arch\\.tar\\.gz"
    install_archive nvim 1
    link_binary nvim "$TOOL_PATH/bin/nvim"
    check_version nvim 0.12.0
fi

if ${install_tool[fzf]}; then
    release_asset junegunn/fzf "fzf-[0-9.]+-linux_$go_arch\\.tar\\.gz"
    install_archive fzf 0
    link_binary fzf "$TOOL_PATH/fzf"
fi

if ${install_tool[starship]}; then
    release_asset starship/starship "starship-$arch-unknown-linux-musl\\.tar\\.gz"
    install_archive starship 0
    link_binary starship "$TOOL_PATH/starship"
fi

if ${install_tool[gh]}; then
    release_asset cli/cli "gh_[0-9.]+_linux_$go_arch\\.tar\\.gz"
    install_archive gh 1
    link_binary gh "$TOOL_PATH/bin/gh"
fi

if ${install_tool[tldr]}; then
    release_asset dbrgn/tealdeer "tealdeer-linux-$arch-musl"
    TOOL_PATH="$TOOLS_DIR/tealdeer-$RELEASE_TAG"
    mkdir -p -- "$TOOL_PATH"
    install --mode=755 "$RELEASE_FILE" "$TOOL_PATH/tldr"
    link_binary tldr "$TOOL_PATH/tldr"
fi

if ${install_tool[node]}; then
    download https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt "$temp_dir/node-checksums"
    node_entry="$(grep -E "^[0-9a-f]{64}  node-v22\\.[0-9.]+-linux-$node_arch\\.tar\\.xz$" "$temp_dir/node-checksums")"
    [[ "$(printf '%s\n' "$node_entry" | wc -l)" == 1 ]] || die "Could not identify the Node.js archive."
    read -r node_digest node_file <<< "$node_entry"
    RELEASE_TAG="${node_file%.tar.xz}"
    RELEASE_FILE="$temp_dir/$node_file"
    download "https://nodejs.org/dist/latest-v22.x/$node_file" "$RELEASE_FILE"
    printf '%s  %s\n' "$node_digest" "$RELEASE_FILE" | sha256sum --check --status
    install_archive node 1
    for name in node npm npx; do
        link_binary "$name" "$TOOL_PATH/bin/$name"
    done
    export PATH="$TOOL_PATH/bin:$PATH"
    check_version node 22.0.0
fi
if ${install_tool[tree-sitter]}; then
    release_asset tree-sitter/tree-sitter "tree-sitter-linux-$node_arch\\.gz"
    TOOL_PATH="$TOOLS_DIR/tree-sitter-$RELEASE_TAG"
    mkdir -p -- "$TOOL_PATH"
    gzip --decompress --stdout "$RELEASE_FILE" > "$TOOL_PATH/tree-sitter"
    chmod +x "$TOOL_PATH/tree-sitter"
    link_binary tree-sitter "$TOOL_PATH/tree-sitter"
    check_version tree-sitter 0.26.1
fi
if ! command -v fd >/dev/null 2>&1; then
    check_binary_slot fd
    link_binary fd "$(command -v fdfind)"
fi
if ! command -v mcp-hub >/dev/null 2>&1; then
    npm install --global --prefix "$HOME/.local" mcp-hub
fi

stow_configs --stow
tldr --update

if ! $skip_plugins; then
    nvim --headless '+Lazy! sync' '+MasonToolsInstallSync' \
        '+lua require("nvim-treesitter").install(require("plugins.nvim-treesitter")[1].opts.parsers):wait(300000)' +qa
    bash "$REPO_DIR/tmux/.config/tmux/plugins/install_tpm.sh"
    socket="$temp_dir/tmux.sock"
    tmux -S "$socket" -f /dev/null new-session -d -s dotfiles-install '/bin/sleep 600'
    tmux -S "$socket" set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins"
    server_pid="$(tmux -S "$socket" display-message -p '#{pid}')"
    TMUX="$socket,$server_pid,0" "$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
fi

printf '%s\n' \
    'Core setup installed. Open a new shell after choosing Zsh with: chsh -s "$(command -v zsh)"' \
    'Authenticate GitHub/Copilot and configure your terminal font separately. See README.md.'
