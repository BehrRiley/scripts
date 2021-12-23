crackshot_events:
    type: world
    debug: false
    config:
        defaults:
            weapons:
                cooldown:
                    on fire:
                        RPG: 30s
                    on switch:
                        default: 3s
    events:
        on player clicks in inventory:
        - if <context.slot.equals[41]> && <context.cursor_item.crackshot_weapon.exists>:
            - determine cancelled
        on player drags in inventory:
        - if <context.slots.contains[41]> && <context.item.crackshot_weapon.exists>:
            - determine cancelled
        on crackshot player starts firing weapon:
        - if <player.has_flag[weapon.<context.weapon>.cooldown]>:
            - narrate "<&c>This weapon is on cooldown. <player.flag_expiration[weapon.<context.weapon>.cooldown].from_now.formatted_words> left."
            #- if <context.weapon.equals[RPG]>:
            #    - give to:<player.inventory> ammunition_rocket quantity:1
            - determine cancelled
        - if <yaml[config].contains[weapons.cooldown.on<&sp>fire.<context.weapon>]>:
            - flag <player> weapon.<context.weapon>.cooldown expire:<yaml[config].read[weapons.cooldown.on<&sp>fire.<context.weapon>]>
        on player scrolls their hotbar:
        - define new <player.inventory.slot[<context.new_slot>]>
        - define old <player.inventory.slot[<context.previous_slot>]>
        - if <[old].crackshot_weapon.exists>:
            - flag <player> weapon.<[old].crackshot_weapon>.cooldown expire:<yaml[config].read[weapons.cooldown.on<&sp>switch.default]>
