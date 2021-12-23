timed_perks_events:
    type: world
    debug: false
    events:
        on mcmmo player gains xp for skill:
        - if <server.has_flag[boosts.mcmmo.xp_multiplier]>:
            - determine <context.xp.mul[<server.flag[boosts.mcmmo.xp_multiplier]>]||<context.xp>>

perks_command:
    type: command
    name: perk
    debug: false
    script:
    - if <context.source_type.to_lowercase.equals[server].not> && <player.has_permission[*].not>:
        - narrate "<&c>This command can only be executed from console."
        - stop
    - choose <context.args.get[1].to_lowercase||>:
        - case mcmmo_xp_boost:
            - if <context.args.get[2].is_decimal.not||true>:
                - stop
            - define mul <context.args.get[2]>
            - define dur <context.args.get[3].as_duration||<duration[1h]>>
            - define duration <server.flag_expiration[boosts.mcmmo.xp_multiplier].from_now.add[<[dur]>]||<[dur]>>
            - announce "<&e>MCMMO <[mul]>x multiplier activated for <[duration].formatted_words>"
            - flag server boosts.mcmmo.xp_multiplier:<[mul]> duration:<[duration]>
        - case crates:
            - if <context.args.get[2].to_lowercase>:

activate_perk:
    type: task
    definitions: perk|player|var1|var2|var3
    data:
        perk_types:
            - mcmmo_xp_boost
            - spawn_supply_crates
            - spawn_military_crates
    debug: false
    script:
    - choose <[perk]>:
        - case mcmmo_xp_boost:
            - define mul <[var1]>
            - if <[mul].is_decimal.not||true>:
                - stop
            - define dur <[var2].as_duration||<duration[1h]>>
            - define duration <server.flag_expiration[boosts.mcmmo.xp_multiplier].from_now.add[<[dur]>]||<[dur]>>
            - announce "<&e><&l><[player]> has purchased MCMMO <[mul]>x server-wide multiplier for <[duration].formatted_words>"
            - flag server boosts.mcmmo.xp_multiplier:<[mul]> duration:<[duration]>
        - case spawn_supply_crates:
            - define amount <[var1]>
            - if <[amount].is_integer.not>:
                - stop
            - repeat <[amount]>:
                - run crates_spawn def:supply|<proc[get_random_point]>|random
            - wait 10t
            - narrate targets:<server.match_player[AJ_4real]> "<&e><&l><[player]> has purchased <[amount]> supply crates from the store."
        - case spawn_military_crates:
            - define amount <[var1]>
            - if <[amount].is_integer.not>:
                - stop
            - repeat <[amount]>:
                - run crates_spawn def:military|<proc[get_random_point]>|random
            - wait 10t
            - narrate targets:<server.match_player[AJ_4real]> "<&e><&l><[player]> has purchased <[amount]> military crates from the store."
