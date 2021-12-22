
turtle_master_cooldown:
    type: world
    debug: false
    config:
        defaults:
            turtle_master_cooldown: 10m
            messages:
                turtle_master_potion_cooldown: <&e>You are on turtle master cooldown. Time Left<&co> <player.flag_expiration[turtle_potion_cooldown].from_now.formatted>
    events:
        on entity potion effects modified:
            - if <context.cause.starts_with[POTION_]>:
                - if <context.effect_type> == DAMAGE_RESISTANCE:
                    - if <player.has_flag[turtle_potion_cooldown]>:
                        - determine passively cancelled
                        - ratelimit <player> 2t
                        - narrate <yaml[config].parsed_key[messages.turtle_master_potion_cooldown]>
                    - else:
                        - flag <player> turtle_potion_cooldown:1 duration:<yaml[config].parsed_key[turtle_master_cooldown]>
                        
health_potion_mod:
    type: world
    debug: false
    config:
        defaults:
            potions:
                healing_multiplier: 1
    events:
        on entity heals because magic:
            - determine <context.amount.mul[<yaml[config].parsed_key[potions.healing_multiplier]>]>