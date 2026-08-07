autoload -Uz compinit && compinit
export VISUAL="nvim"
export EDITOR="nvim"
alias ls="ls --color=auto"
export ANTHROPIC_API_KEY=$(security find-generic-password -a "$USER" -s "anthropic-api-key" -w)
bindkey -e

autoload edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

setopt prompt_subst
git_prompt() {
    local branch dirty=""
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || return
    git status --porcelain -u 2>/dev/null | grep -q . && dirty+="*"
    git rev-parse --verify refs/stash &>/dev/null && dirty+="\$"
    git status -sb 2>/dev/null | grep -q "\[ahead" && dirty+=">"
    echo " %F{green}${branch}%f%F{red}${dirty}%f"
}
PROMPT="%F{blue}%~%f$(git_prompt) %# "
RPROMPT="%(1j.%F{cyan}[%j]%f .)%*"
