autoload -Uz compinit && compinit
bindkey '\e[91;5u' vi-cmd-mode # vi mode escape binding for ghostty
export VISUAL='nvim'
export EDITOR="$VISUAL"
alias ls='ls --color=auto'
alias dv='nvim -c :DiffviewOpen'
export ANTHROPIC_API_KEY=$(security find-generic-password -a "$USER" -s "anthropic-api-key" -w)

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

alias cdev='npx convex dev --tail-logs'
users() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: users <searchPattern...>"
        return 1
    fi
    local searchPattern="$1"
    local jsonPayload=$(jq -n \
                        --arg searchString "$searchPattern" \
                        '{searchString: $searchString}')
    echo "Searching for workspaces with search pattern: $searchPattern"
    npx convex run workspaces/members:_getUserWorkspaceInformation "$jsonPayload" --prod
}
function lfc() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: lfcontact <contact_id>"
        return 1
    fi
    local contact_id="$*"
    local filter="metadata;stringObject;contactId;=;$contact_id"
    local encoded_filter=$(printf '%s' "$filter" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))")
    local url="https://cloud.langfuse.com/project/clqpk29x10000tzmpeyudr9ql/traces?filter=$encoded_filter"
    echo "Opening Langfuse with contact ID: $contact_id"
    open "$url"
}
