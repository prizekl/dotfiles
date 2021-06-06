# PS1='%S%F{cyan}%n%F{cyan} %F{cyan}%1~ %F{cyan}%#%s%F{reset} '
# export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'

if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden'
  export FZF_DEFAULT_OPTS="--preview 'bat --color=always --style=header,grid --line-range :300 {}'"
fi

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
# PROMPT=\$vcs_info_msg_0_'%# '
zstyle ':vcs_info:git:*' formats '%b'

export BAT_THEME="Visual Studio Dark+"

if [ "$TMUX" = "" ]; then
  tmux new -s Alpha
fi

