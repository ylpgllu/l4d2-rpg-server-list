#!/bin/bash
api_key="$1"
if [ ${#api_key} -ne 32 ]; then
    echo -e "Usage: \n\t $(basename "$0") API_KEY\n"
    echo "ERROR: need a valid api_key, get it from https://steamcommunity.com/dev/apikey"
    exit 1
fi

rpg_name_pattern=$(echo '
      [^非]RPG
    | 上帝之手
    | 弑神巅峰
    | 暗黑之魂
    | 趣味
    | 天下
    | 神域
    | 完美世界
    | 一念仙行录
    | 窥仙之路
    | 风花雪月
    | 暗黑之魂
    | 午夜狂欢
    | 無人永生
    | 神之右手
    | 军魂
    | 星缘
    | 破晓
    | 腐尸之地
    | 猎人
    | 通天塔
    | 无法逃脱
    | 穷途末路
    | 烈焰
    | 经典怀旧服
    | 星缘天空
    | 紫金之巅
    | 梦幻天堂
    | AK0048
    | 杀戮时刻
    | 杀戮世界
    | Tank杀戮
    | 橡子杀戮
    | 幻想杀戮
    | CN
    | 夏洛克
    | 无限火力
    | 643057081
    | 多特	
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
