flag_handlers:
    type: world
    debug: false
    events:
        on player dies:
        - flag <player> death_location:<player.location>
        on entity damaged by suffocation:
        - if <player||null> != null:
            - if <player.has_flag[no_suffocate]>:
                - determine cancelled
        on entity killed by fall:
        - if <player||null> != null:
            - if <player.has_flag[no_fall]>:
                - determine cancelled
        on entity damaged by fall:
        - if <player||null> != null:
            - if <player.has_flag[no_fall]>:
                - determine cancelled
        on player killed:
        - if <player||null> != null:
            - if <player.has_flag[no_damage]>:
                - determine cancelled
        on player damaged:
        - if <player||null> != null:
            - if <player.has_flag[no_damage]>:
                - determine cancelled
            - if <player.has_flag[damage_zero]>:
                - determine 0.0
        # on crackshot weapon damages entity ignorecancelled:true:
        on player damages player bukkit_priority:monitor ignore_cancelled:true:
        - if <context.entity.has_flag[no_pvp_damage]> || <context.damager.has_flag[no_pvp_damage]>:
            - determine cancelled
        on entity damages entity bukkit_priority:monitor ignorecancelled:true:
        - if <context.entity.has_flag[no_pvp_damage].or[<context.damager.has_flag[no_pvp_damage]>]> && <context.entity.is_player> && <context.damager.is_player>:
            - determine cancelled
        - if <context.entity.has_flag[no_damage]>:
            - determine cancelled
        - if <context.entity.has_flag[damage_zero]>:
            - determine 0.0
        on player jumps:
        - if <player||null> != null:
            - if <player.has_flag[no_jump]> || <player.has_flag[no_move]>:
                - determine cancelled
        on entity knocks back entity:
        - if <context.entity.has_flag[no_knockback]||false> || <context.entity.has_flag[no_move]||false>:
            - determine cancelled
        on player walks:
        - if <player||null> != null:
            - if <player.has_flag[no_move]>:
                - determine cancelled
        on tick:
        - foreach <server.list_online_players.filter[has_flag[downpull]]> as:player:
            - adjust <[player]> velocity:<[player].velocity.add[<location[0,<[player].flag[downpull]||-0.02>,0]>]>
        on player joins:
        - if <player.has_flag[vanish]>:
            - determine NONE
        on player quit:
        - if <player.has_flag[vanish]>:
            - determine NONE

no_slash_op:
    type: world
    debug: false
    events:
        on command:
        - if <context.command> == op && <context.source_type> != SERVER:
            - narrate no
            - determine passively cancelled
