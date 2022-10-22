# autoload -Uz vcs_info
# precmd_vcs_info() { vcs_info }
# precmd_functions+=( precmd_vcs_info )
# setopt prompt_subst
# zstyle ':vcs_info:git:*' formats '%b'
# RPROMPT=\$vcs_info_msg_0_
# if [ "$TMUX" = "" ]; then tmux; fi

alias ls='exa'
alias ll='exa -l'
alias l='exa -la'
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
