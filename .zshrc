# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

autoload -Uz compinit && compinit
export VISUAL='nvim'
export EDITOR="$VISUAL"
alias ls='exa'
eval "$(atuin init zsh)"
alias cdev='npx convex dev --tail-logs'
alias diffview='nvim -c :DiffviewOpen'
export HISTIGNORE="fg*"
bindkey '\e[91;5u' vi-cmd-mode # vi mode escape binding for ghostty

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


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/prizel/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/prizel/Downloads/google-cloud-sdk/path.zsh.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/Users/prizel/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/prizel/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
