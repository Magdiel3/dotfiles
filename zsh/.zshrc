# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt beep
bindkey -v
# End of lines configured by zsh-newuser-install

alias v="nvim"
alias tree="tree -I .git -a"

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
