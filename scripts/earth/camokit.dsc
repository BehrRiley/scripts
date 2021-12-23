camo_kit_events:
    type: world
    debug: false
    events:
        after player unequips armor:
        - if <player.equipment.filter[material.name.to_lowercase.starts_with[leather]].filter[color.equals[co@94,124,22]].size> != 4 && <player.has_flag[camo]>:
            - narrate "<&c>Deactivated Camouflage's Kit."
            - flag <player> camo:!
        after player equips armor:
        - if <player.equipment.filter[material.name.to_lowercase.starts_with[leather]].filter[color.equals[co@94,124,22]].size> == 4 && !<player.has_flag[camo]>:
            - narrate "<&c>Activated Camouflage's Kit."
            - flag <player> camo
        after player joins:
        - if <player.equipment.filter[material.name.to_lowercase.starts_with[leather]].filter[color.equals[co@94,124,22]].size> == 4 && !<player.has_flag[camo]>:
            - narrate "<&c>Activated Camouflage's Kit."
            - flag <player> camo
        on entity targets player:
        - if <player.has_flag[camo]> && <context.reason.equals[CLOSEST_PLAYER]>:
            - determine cancelled
