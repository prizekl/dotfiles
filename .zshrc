# # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# # Initialization code that may require console input (password prompts, [y/n]
# # confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
# source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

autoload -Uz compinit && compinit
export VISUAL='nvim'
export EDITOR="$VISUAL"
alias ls='exa'
alias cdev='npx convex dev --tail-logs'
alias diffview='nvim -c :DiffviewOpen'
export HISTIGNORE="fg*"
bindkey '\e[91;5u' vi-cmd-mode # vi mode escape binding for ghostty
export ANTHROPIC_API_KEY=$(security find-generic-password -a "$USER" -s "anthropic-api-key" -w)

users() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: users <searchPattern...>"
        return 1
    fi
    # Concatenate all remaining arguments as the search pattern
    local searchPattern="$1"
    # Construct the JSON payload including the userId and searchString
    local jsonPayload=$(jq -n \
                        --arg searchString "$searchPattern" \
                        '{searchString: $searchString}')
    # Fetch the data
    echo "Searching for workspaces with search pattern: $searchPattern"
    npx convex run workspaces/members:_getUserWorkspaceInformation "$jsonPayload" --prod
}

setopt prompt_subst
git_prompt() {
    local branch dirty=""
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || return
    git status --porcelain -u 2>/dev/null | grep -q . && dirty+="*"
    git rev-parse --verify refs/stash &>/dev/null && dirty+="\$"
    git status -sb 2>/dev/null | grep -q '\[ahead' && dirty+=">"
    echo " %F{green}${branch}%f%F{red}${dirty}%f"
}
PROMPT='%F{blue}%~%f$(git_prompt) %# '
RPROMPT='%(1j.%F{cyan}[%j]%f .)%*'
