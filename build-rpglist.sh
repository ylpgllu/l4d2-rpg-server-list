#!/bin/bash
api_key="$1"
if [ ${#api_key} -ne 32 ]; then
    echo -e "Usage: \n\t $(basename "$0") API_KEY\n"
    echo "ERROR: need a valid api_key, get it from https://steamcommunity.com/dev/apikey"
    exit 1
fi

rpg_name_pattern=$(echo '
    Valve
    |Hong
    |Japan
    |Asia	
    ' \
    | tr -d '[:space:]'
)

curl -sS --get \
    'http://api.steampowered.com/IGameServersService/GetServerList/v1' \
    --header 'Accept: application/json' \
    --data-urlencode "key=$api_key" \
    --data-urlencode "filter=\appid\550\nor\9\gametype\official\white\1\region\0\region\1\region\2\region\3\region\5\region\6\region\7" \
    --data-urlencode "limit=1000000" \
| jq '
    {
        "ver": "5.1",
        "tag": "ipblacklist",
        "data": [
            .response.servers[]
            | with_entries( select([.key] | inside( ["name", "addr"] )) )
            | select( .name | test("'"$rpg_name_pattern"'") )
            | .addr = (.addr | split(":") | .[0])
            | .["raddr"] = .addr | del(.addr)
            | .["memo"] = .name | del(.name)
        ]
        | unique_by(.raddr)
    }' \
> rpglist-$(date '+%Y-%m-%d').json
cp rpglist-$(date '+%Y-%m-%d').json rpglist-latest.json
