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

users() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: users <searchPattern>"
        return 1
    fi
    local searchPattern="$1"
    npx convex data users --prod --limit 500 | rg "$searchPattern" | awk -F '|' '{print $1, $4, $8}'
}

decrypt() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: integrations <searchPattern>"
        return 1
    fi
    local searchPattern="$1"
    local encryptedString=$(npx convex data integrations --prod --limit 500 | rg "$searchPattern" | awk -F '|' '{print $3}' | tr -d ' ')
    if [ ! -z "$encryptedString" ]; then
        # Debug: Print the raw encryptedString
        local jsonPayload="{\"token\": $encryptedString}"
    # Debug: Print the constructed JSON payload
    echo "JSON Payload: $jsonPayload"
    npx convex run actions/pmsIntegrations:decryptString "$jsonPayload" --prod
else
    echo "No matching data found or error in extracting the encrypted string."
    return 1
    fi
}
