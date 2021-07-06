autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
# PROMPT=\$vcs_info_msg_0_'%# '
zstyle ':vcs_info:git:*' formats '%b'

export FZF_DEFAULT_OPTS=" --preview-window=up,50% --preview 'bat --color=always --style=header,grid --line-range :300 {}'"

export BAT_THEME="Visual Studio Dark+"

if [ "$TMUX" = "" ]; then
  tmux
fi

# if type rg &> /dev/null; then
#   export FZF_DEFAULT_COMMAND='rg --files --hidden'
# fi
# PS1='%S%F{cyan}%n%F{cyan} %F{cyan}%1~ %F{cyan}%#%s%F{reset} '
# PS1='%F{33}%n%F{33} %F{33}%1~ %F{33}%#%F{reset} '
# PS1='%n %1~ %F{33}%#%F{reset} '
