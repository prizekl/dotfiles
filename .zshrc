# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

alias ls='exa'
eval "$(atuin init zsh)"
alias gs='git status'
function gac() {
    git add .
    local commitMessage="$*"
    git commit -a -m "$commitMessage"
}

alias cdev='npx convex dev --tail-logs'

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
        echo "Usage: convo <workspaceId> <searchPattern...>"
        return 1
    fi

    local workspaceId="$1"
    shift # Remove the first argument, so only search patterns remain

    # Concatenate all remaining arguments as the search pattern
    local searchPattern="$*"

    # Construct the JSON payload including the workspaceId and searchString
    local jsonPayload=$(jq -n \
                        --arg workspaceId "$workspaceId" \
                        --arg searchString "$searchPattern" \
                        '{workspaceId: $workspaceId, searchString: $searchString}')

    # Fetch the data
    echo "Fetching data for workspace ID: $workspaceId with search pattern: $searchPattern"
    npx convex run conversations:_getByWorkspaceIdSearch "$jsonPayload" --prod | \
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

moment() {
    local input_date=$1
    local output_format="+%Y-%m-%d %H:%M:%S"

    # Detect and convert various date formats
    if echo "$input_date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        # Format: YYYY-MM-DD
        date -j -f "%Y-%m-%d" "$input_date" "$output_format"
    elif echo "$input_date" | grep -qE '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'; then
        # Format: MM/DD/YYYY
        date -j -f "%m/%d/%Y" "$input_date" "$output_format"
    elif echo "$input_date" | grep -qE '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'; then
        # Format: YYYY/MM/DD
        date -j -f "%Y/%m/%d" "$input_date" "$output_format"
    elif echo "$input_date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'; then
        # Format: YYYY-MM-DD HH:MM:SS
        date -j -f "%Y-%m-%d %H:%M:%S" "$input_date" "$output_format"
    elif echo "$input_date" | grep -qE '^[0-9]{13}$'; then
        # Format: Unix timestamp in milliseconds
        date -r $(($input_date / 1000)) "$output_format"
    elif echo "$input_date" | grep -qE '^[0-9]{10}$'; then
        # Format: Unix timestamp in seconds
        date -r "$input_date" "$output_format"
    else
        echo "Unknown date format"
    fi
}
