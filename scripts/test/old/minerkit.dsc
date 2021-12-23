miner_kit_events:
    type: world
    debug: false
    events:
        on player unequips armor:
        - if <player.equipment.filter[material.name.to_lowercase.starts_with[iron]].size> != 4 && <player.has_flag[miner]>:
            - narrate "<&c>Deactivated Miner's Kit."
            - flag <player> miner:!
            - cast FAST_DIGGING amplifier:1 duration:0t
            - cast FIRE_RESISTANCE amplifier:0 duration:0t
            - cast SPEED amplifier:0 duration:0t
        on player equips armor:
        - if <player.equipment.filter[material.name.to_lowercase.starts_with[iron]].size> == 4 && !<player.has_flag[scout]>:
            - narrate "<&c>Activated Miner's Kit."
            - flag <player> miner
            - cast FAST_DIGGING amplifier:1 duration:100m
            - cast FIRE_RESISTANCE amplifier:0 duration:100m
            - cast SPEED amplifier:0 duration:100m
