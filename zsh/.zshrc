
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt beep
bindkey -v
# End of lines configured by zsh-newuser-install

alias v="nvim"
alias tree="tree -I .git -a"
alias bat="/usr/bin/batcat"
alias ta="tmux a"
alias inv="./invoke"
alias hs="hunk show"

# Capture double jj in --input-- mode to exit to normal
function vi-jj-exit() {
  # If the last two characters were 'j' and 'j', exit to normal mode
  # The first j is captured before calling this function
  if [[ $LBUFFER == *j ]]; then
    LBUFFER=${LBUFFER%j}
    zle vi-cmd-mode
  else
    zle self-insert
  fi
}

zle -N vi-jj-exit
bindkey -M viins 'j' vi-jj-exit

# Set the editor to nvim
EDITOR=nvim

# Source the configure completions
COMPLETIONS_FILE="${HOME}/.zsh/completions.zsh"
[[ -f ${COMPLETIONS_FILE} ]] && source ${COMPLETIONS_FILE}

# Source the Pure prompt
PROMPT_SETUP_FILE="${HOME}/.zsh/prompt_setup.zsh"
[[ -f $PROMPT_SETUP_FILE ]] && source ${PROMPT_SETUP_FILE}

# Source the graphite autocompletion script
GRAPHITE_COMPLETION_SCRIPT="${HOME}/.zsh/gh_completion.zsh"
[[ -f $GRAPHITE_COMPLETION_SCRIPT ]] && source ${GRAPHITE_COMPLETION_SCRIPT}

# Source the bazel completion script
BAZEL_COMPLETION_SCRIPT="${HOME}/.zsh/bazel_completion.zsh"
[[ -f $BAZEL_COMPLETION_SCRIPT ]] && source ${BAZEL_COMPLETION_SCRIPT}

# Source the opencode completion script
OPENCODE_COMPLETION_SCRIPT="${HOME}/.zsh/opencode_completion.zsh"
[[ -f "$OPENCODE_COMPLETION_SCRIPT" ]] && source "$OPENCODE_COMPLETION_SCRIPT"

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load the SSH agent if not already running
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env

# Keep private and machine-specific settings outside this repository.
LOCAL_ZSHRC_KEYS_FILE="${HOME}/.zshrc_local"
[[ -f "$LOCAL_ZSHRC_KEYS_FILE" ]] && source "$LOCAL_ZSHRC_KEYS_FILE"

export PATH=$PATH:/usr/local/go/bin

. "$HOME/.local/bin/env"

[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Copilot CLI keychain/keyring integration
# Install with `sudo apt install gnome-keyring libsecret-tools`
if command -v gnome-keyring-daemon >/dev/null 2>&1; then
    eval "$(gnome-keyring-daemon --start --components=secrets)"
fi

# Hunk (https://hunk.dev)
export PATH="$HOME/.hunk/bin:$PATH"
