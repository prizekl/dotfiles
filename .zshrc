autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '%b'
RPROMPT=\$vcs_info_msg_0_

eval "$(zoxide init zsh)"

if [ "$TMUX" = "" ]; then tmux; fi
