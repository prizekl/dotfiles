autoload -Uz compinit && compinit
export VISUAL="nvim"
export EDITOR="nvim"
alias ls="ls --color=auto"
export ANTHROPIC_API_KEY=$(security find-generic-password -a "$USER" -s "anthropic-api-key" -w)
bindkey -e

autoload edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
