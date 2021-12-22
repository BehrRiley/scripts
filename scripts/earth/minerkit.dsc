miner_kit_events:
    type: world
    debug: false
    events:
        after player unequips armor:
        - if <player.equipment.filter[material.name.to_lowercase.starts_with[iron]].size> != 4 && <player.has_flag[kits.miner]>:
            - narrate "<&c>Deactivated Miner's Kit."
            - flag <player> kits.miner:!
            - cast FAST_DIGGING duration:0t
            - cast FIRE_RESISTANCE duration:0t
            - cast SPEED duration:0t
            - cast NIGHT_VISION duration:0t
        after player equips armor:
        - if <player.equipment.filter[material.name.to_lowercase.starts_with[iron]].size> == 4 && !<player.has_flag[kits.miner]>:
            - narrate "<&c>Activated Miner's Kit."
            - flag <player> kits.miner
            - cast FAST_DIGGING duration:1000h
            - cast FIRE_RESISTANCE duration:1000h
            - cast SPEED duration:1000h
            - cast NIGHT_VISION duration:1000h
        after player joins:
        - if <player.equipment.filter[material.name.to_lowercase.starts_with[iron]].size> == 4 && !<player.has_flag[kits.miner]>:
            - narrate "<&c>Activated Miner's Kit."
            - flag <player> kits.miner
            - cast FAST_DIGGING duration:1000h
            - cast FIRE_RESISTANCE duration:1000h
            - cast SPEED duration:1000h
            - cast NIGHT_VISION duration:1000h
        on delta time minutely:
        - foreach <server.online_players_flagged[kits.miner]>:
            - cast FAST_DIGGING duration:1000h <[value]>
            - cast FIRE_RESISTANCE duration:1000h <[value]>
            - cast SPEED duration:1000h <[value]>
            - cast NIGHT_VISION duration:1000h <[value]>