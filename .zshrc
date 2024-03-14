alias ls='exa'
alias python="python3"
alias cdev='npx convex dev --tail-logs'
alias gs='git status'
function gac() {
    git add .
    local commitMessage="$*"
    git commit -a -m "$commitMessage"
}
eval "$(starship init zsh)"
