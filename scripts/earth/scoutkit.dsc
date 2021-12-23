scout_kit_events:
    type: world
    debug: false
    events:
        after player unequips armor:
        - if <player.equipment.filter[material.name.to_lowercase.starts_with[leather]].size> != 4 && <player.has_flag[scout]>:
            - narrate "<&c>Deactivated Scout's Kit."
            - flag <player> scout:!
            - execute as_server "dynmap show <player.name>"
        after player equips armor:
        - if <player.equipment.filter[material.name.to_lowercase.starts_with[leather]].size> == 4 && !<player.has_flag[scout]>:
            - narrate "<&c>Activated Scout's Kit."
            - flag <player> scout
            - execute as_server "dynmap hide <player.name>"
        after player joins:
        - if <player.equipment.filter[material.name.to_lowercase.starts_with[leather]].size> == 4 && !<player.has_flag[scout]>:
            - narrate "<&c>Activated Scout's Kit."
            - flag <player> scout
            - execute as_server "dynmap hide <player.name>"
