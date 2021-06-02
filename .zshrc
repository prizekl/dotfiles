# PS1='%S%F{cyan}%n%F{cyan} %F{cyan}%1~ %F{cyan}%#%s%F{reset} '
# export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'

if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden'
  export FZF_DEFAULT_OPTS="--preview 'bat --color=always --style=header,grid --line-range :300 {}'"
fi

export BAT_THEME="Visual Studio Dark+"

if [ "$TMUX" = "" ]; then
  tmux new -s Alpha
fi

