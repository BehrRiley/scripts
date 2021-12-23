new_player_eventss:
    type: world
    debug: false
    events:
        on player joins:
        - flag <player> skin.blob:<player.skin_blob>
        - flag <player> skin.skull:<player.skull_skin>
        - wait 1t
        - if <player.has_flag[joinedd]>:
            - stop
        - flag <player> no_pvp_damage:true duration:24h
        - wait 1t
        - money give players:<player> quantity:500
        - flag <player> joinedd
        - foreach <yaml[config].list_keys[new_player.kit]||<list[]>> as:slot:
            - inventory set d:<player.inventory> slot:<[slot]> o:<yaml[config].read[new_player.kit.<[slot]>]>
        - wait 1s
        - inject get_random_point_task
        - teleport <player> <[loc]>
        - flag <player> no_fall duration:1m
        - wait 60s
        - flag <player> no_fall:!
        on delta time secondly every:10:
        - foreach <server.online_players.filter[has_flag[no_pvp_damage]]> as:p:
            - townymeta <[p]> key:orbis.pvp_protection value:<[p].flag_expiration[no_pvp_damage].from_now.formatted_words||Unknown> "label:PVP Protection"
        - foreach <server.online_players.filter[has_flag[no_pvp_damage].not]> as:p:
            - townymeta <[p]> key:orbis.pvp_protection value:Disabled "label:PVP Protection"
