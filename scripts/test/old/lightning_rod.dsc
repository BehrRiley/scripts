lightning_rod_events:
    type: world
    debug: false
    config:
        defaults:
            lightning_rod:
                strike_delay_after_impact: 40
                strike_radius: 2
                strike_radius_when_thundering: 4
                animation_intensity: 3
    events:
        on player picks up launched arrow:
            - if <context.arrow.entity_type> == TRIDENT && <context.item.script.name||null> == lightning_rod_item:
                - determine passively cancelled
        on projectile hits block:
            - if <context.projectile.item.script.name||null> != lightning_rod_item:
                - stop
            - if <context.projectile.location.world.thundering>:
                - define radius <yaml[config].parsed_key[lightning_rod.strike_radius_when_thundering]||2>
            - else:
                - define radius <yaml[config].parsed_key[lightning_rod.strike_radius]||2>
            - repeat <yaml[config].parsed_key[lightning_rod.strike_delay_after_impact]||40>:
                - if !<context.projectile.is_spawned>:
                    - stop
                - repeat <yaml[config].parsed_key[lightning_rod.animation_intensity]||3>:
                    - playeffect redstone at:<proc[define_zigzag].context[<context.projectile.location>|<context.projectile.location.random_offset[<[radius]>]>|1|1|2]> offset:0 visibility:300 quantity:1 special_data:1|<color[255,241,87]>
                - wait 1t
            - define loc <context.projectile.location>
            - define locations <context.projectile.location.find.surface_blocks.within[<[radius]>]>
            - define locations <[locations].random[<[locations].size.div[7].round>]>
            - define t 1
            - define p <context.projectile.flag[user].as_player>
            - if <context.projectile.location.has_town>:
                - if !<context.projectile.location.town.has_pvp>:
                    - give <[p]> <context.projectile.item>
                    - remove <context.projectile>
                    - stop
            - remove <context.projectile>
            - foreach <[loc].find.players.within[3]>:
                - if !<proc[check_hit_perms_l1].context[<[p]>|<[value]>]>:
                    - define pl:|:<[value]>
                    - flag <[value]> friendly:<[p]>
            - foreach <[locations]> as:l:
                - strike <[l]>
                - if <[t]> == 7:
                    - wait 1t
                    - define t 1
                - else:
                    - define t <[t].add[1]>
            - wait 10t
            - foreach <[pl]||<list[]>>:
                - flag <[value]> friendly:!
        on entity damaged by lightning:
            - if <context.entity.has_flag[friendly]>:
                - determine passively cancelled
        on entity shoots block:
            - if <context.projectile.item.script.name||null> == lightning_rod_item && <context.shooter.is_player>:
                - flag <context.projectile> user:<context.shooter>

lightning_rod_item:
    type: item
    material: trident
    display name: <&e>Lightning Rod