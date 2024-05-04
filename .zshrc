# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

alias ls='exa'
alias python="python3"
alias cdev='npx convex dev --tail-logs'
alias gs='git status'
function gac() {
    git add .
    local commitMessage="$*"
    git commit -a -m "$commitMessage"
}

# eval "$(starship init zsh)"

users() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: users <searchPattern>"
        return 1
    fi
    local searchPattern="$*"
    npx convex data users --prod --limit 600 | rg -i "$searchPattern" | awk -F '|' '{print $1, $4, $8}'
}

decrypt() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: decrypt <searchPattern>"
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

convo_id() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: convo_id <conversationId> [<searchPattern...>]"
        return 1
    fi

    local conversationId="$1"
    shift # Remove the first argument, so only search patterns remain

    # Concatenate all remaining arguments as the search pattern, if any
    local searchPattern="$*"

    # Check if the input is a number and construct JSON payload accordingly
    local jsonPayload
    if [[ "$conversationId" =~ ^[0-9]+$ ]]; then
        # Input is numeric, construct JSON payload with numeric conversationId
        jsonPayload=$(jq -n --argjson conversationId "$conversationId" --arg searchString "$searchPattern" \
                        '{"conversationId": $conversationId, "searchString": $searchString}')
    else
        # Input is not numeric, treat it as a string
        jsonPayload=$(jq -n --arg conversationId "$conversationId" --arg searchString "$searchPattern" \
                        '{"conversationId": $conversationId, "searchString": $searchString}')
    fi

    # Fetch the data using the constructed JSON payload
    echo "Fetching data for conversation ID: $conversationId"
    npx convex run conversations:_getById "$jsonPayload" --prod | jq --arg pattern "$searchPattern" '
        if ($pattern | length) > 0 then
            map(select(
                . as $object |
                any(values[]; tostring | test($pattern; "i"))
            ))
        else
            .
        end
    '
}

convo_search() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: convo <userId> <searchPattern...>"
        return 1
    fi

    local userId="$1"
    shift # Remove the first argument, so only search patterns remain

    # Concatenate all remaining arguments as the search pattern
    local searchPattern="$*"

    # Construct the JSON payload including the userId and searchString
    local jsonPayload=$(jq -n \
                        --arg userId "$userId" \
                        --arg searchString "$searchPattern" \
                        '{userId: $userId, searchString: $searchString}')

    # Fetch the data
    echo "Fetching data for user ID: $userId with search pattern: $searchPattern"
    npx convex run conversations:_getByUserIdSearch "$jsonPayload" --prod | \
    jq --stream --arg pattern "$searchPattern" '
        fromstream(1|truncate_stream(inputs)) | 
        select(
            . as $object | 
            any(values[]; tostring | test($pattern))
        )
    '
}

res_id() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: res_id <reservationId> [<searchPattern...>]"
        return 1
    fi

    local reservationId="$1"
    shift # Remove the first argument, so only search patterns remain

    # Concatenate all remaining arguments as the search pattern, if any
    local searchPattern="$*"

    # Check if the input is a number and construct JSON payload accordingly
    local jsonPayload
    if [[ "$reservationId" =~ ^[0-9]+$ ]]; then
        # Input is numeric, construct JSON payload with numeric reservationId
        jsonPayload=$(jq -n --argjson reservationId "$reservationId" --arg searchString "$searchPattern" \
                        '{"reservationId": $reservationId, "searchString": $searchString}')
    else
        # Input is not numeric, treat it as a string
        jsonPayload=$(jq -n --arg reservationId "$reservationId" --arg searchString "$searchPattern" \
                        '{"reservationId": $reservationId, "searchString": $searchString}')
    fi

    # Fetch the data using the constructed JSON payload
    echo "Fetching data for reservation ID: $reservationId"
    npx convex run reservations:_getById "$jsonPayload" --prod | jq --arg pattern "$searchPattern" '
        if ($pattern | length) > 0 then
            map(select(
                . as $object |
                any(values[]; tostring | test($pattern; "i"))
            ))
        else
            .
        end
    '
}

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
