napalm_entity:
    type: entity
    entity_type: falling_block
    mechanisms:
        fallingblock_type: fire

napalm_item:
    type: item
    material: blaze_powder
    display name: <&r><&c>Napalm
    recipes:
        1:
            type: shapeless
            input: blaze_powder|blaze_powder|gunpowder|fire_charge|fire_charge|lava_bucket

napalm_handler:
    type: world
    debug: false
    config:
        defaults:
            napalm:
                enabled: true
                enable_recipe: false
                fire_spawned_per_tick: 2
                spawning_duration_in_ticks: 30
                explosive_power: 2
                fire_explosive: true
                explosion_breaks_blocks: true
                spawn_spread: 0.3
    events:
        on reload scripts:
        - if !<yaml[config].parsed_key[napalm.enable_recipe]>:
            - adjust server remove_recipes:<item[napalm_item].recipe_ids>
        on player clicks block:
        - if !<yaml[config].parsed_key[napalm.enabled]>:
            - stop
        - if <context.item.script.name||null> != napalm_item:
            - stop
        - if <player.location.town.name||null> != <player.town.name||null> && <player.town.name||null> != null && <player.location.town.name||null> != null:
            - narrate <yaml[config].parsed_key[messages.cannot_use_item_here]>
            - stop
        - if !<player.location.is_wilderness||true>:
            - narrate <yaml[config].parsed_key[messages.cannot_use_item_here]>
            - stop
        - if <context.item.script.name||null> == null:
            - stop
        - if <context.item.script.name> != napalm_item:
            - stop
        - if !<context.click_type.starts_with[RIGHT_CLICK]>:
            - stop
        - if <player.gamemode> != CREATIVE:
            - adjust <player> item_in_hand:<player.item_in_hand.with[quantity=<player.item_in_hand.quantity.sub[1]>]>
        - define spread <yaml[config].parsed_key[napalm.spawn_spread]>
        - repeat <yaml[config].parsed_key[napalm.spawning_duration_in_ticks]>:
            - if <player.location.town.name||null> == <player.town.name||null> || <player.location.is_wilderness||true>:
                - if !<player.is_spawned>:
                    - stop
                - playeffect effect:landing_lava at:<player.location> quantity:100 offset:<player.location.with_x[2].with_y[0.5].with_z[2]>
                - repeat 100:
                    - playeffect effect:flame at:<player.location> quantity:1 velocity:<player.location.with_x[<util.random.decimal[-0.7].to[0.7]>].with_y[<util.random.decimal[-2].to[-1]>].with_z[<util.random.decimal[-0.7].to[0.7]>]>
                - repeat <yaml[config].parsed_key[napalm.fire_spawned_per_tick]>:
                    - spawn at:<player.location> <entity[napalm_entity]> save:entity
                    - adjust <entry[entity].spawned_entity> velocity:<player.location.with_x[<util.random.decimal[-<[spread]>].to[<[spread]>]>].with_y[0].with_z[<util.random.decimal[-<[spread]>].to[<[spread]>]>].add[<player.velocity>]>
                    - flag <entry[entity].spawned_entity> napalm
                - wait 1t
            - else:
                - repeat stop
        on block falls:
        - if !<yaml[config].parsed_key[napalm.enabled]>:
            - stop
        - if <context.entity.has_flag[napalm]>:
            - define map <map[]>
            - determine passively cancelled
            - foreach <context.location.find_entities.within[5]> as:e:
                - define map <[map].with[<[e]>].as[<[e].velocity>]>
            - if <yaml[config].parsed_key[napalm.fire_explosive]||true>:
                - if <yaml[config].parsed_key[napalm.explosion_breaks_blocks]||false>:
                    - explode <context.location> power:<yaml[config].parsed_key[napalm.explosive_power]||1> fire breakblocks
                - else:
                    - explode <context.location> power:<yaml[config].parsed_key[napalm.explosive_power]||1> fire
            - else:
                - if <yaml[config].parsed_key[napalm.explosion_breaks_blocks]||false>:
                    - explode <context.location> power:<yaml[config].parsed_key[napalm.explosive_power]||1> breakblocks
                - else:
                    - explode <context.location> power:<yaml[config].parsed_key[napalm.explosive_power]||1>
            - foreach <[map].keys> as:e:
                - adjust <[e]> velocity:<[map].get[<[e]>]>

napalm_flare_item:
    type: item
    material: snowball
    display name: Flare

napalm_flare_events:
    type: world
    debug: false
    passive:
    - repeat 60:
        - playeffect campfire_signal_smoke at:<[location]> quantity:15 offset:0.2 visibility:100 velocity:<location[<util.random.decimal[-0.1].to[0.1]>,0.3,<util.random.decimal[-0.1].to[0.1]>]>
        - wait 1t
    spawn:
    - define loc <[location].with_y[<[location].y.add[100]>].with_pitch[90].with_yaw[<util.random.decimal[0].to[360]>]>
    - run napalm_flare_events path:passive defmap:<map[location=<[location]>]>
    - define a <[loc].forward_flat[50]>
    - define b <[loc].backward_flat[50]>
    - foreach <[a].points_between[<[b]>].distance[1]> as:point:
        - playeffect effect:landing_lava at:<[point]> quantity:100 offset:<[point].with_x[2].with_y[0.5].with_z[2]>
        - repeat 100:
            - playeffect effect:flame at:<[point]> quantity:1 velocity:<[point].with_x[<util.random.decimal[-0.7].to[0.7]>].with_y[<util.random.decimal[-2].to[-1]>].with_z[<util.random.decimal[-0.7].to[0.7]>]>
        - repeat <yaml[config].parsed_key[napalm.fire_spawned_per_tick]>:
            - spawn at:<[point]> <entity[napalm_entity]> save:entity
            - adjust <entry[entity].spawned_entity> velocity:<location[<util.random.decimal[-0.2].to[0.2]>,0.3,<util.random.decimal[-0.2].to[0.2]>]>
            - flag <entry[entity].spawned_entity> napalm
        - wait 1t
    events:
        on projectile launched:
        - if !<yaml[config].parsed_key[napalm.enabled]>:
            - stop
        - if <context.entity.item.script.name||null> == napalm_flare_item:
            - flag <context.entity> napalm_flare
            - adjust <context.entity> velocity:<context.entity.velocity.div[2]>
            - wait 3t
            - while <context.entity.is_spawned>:
                - playeffect campfire_signal_smoke at:<context.entity.location> quantity:15 offset:0.2 visibility:100 velocity:<location[<util.random.decimal[-0.1].to[0.1]>,0.3,<util.random.decimal[-0.1].to[0.1]>]>
                - wait 1t
        on snowball hits entity:
        - if <context.projectile.has_flag[napalm_flare]>:
            - define num <context.projectile.flag[bounce_number]||0>
            - define velocity <context.projectile.velocity>
            - define location <context.projectile.location>
            - inject napalm_flare_events spawn
        on snowball hits block:
        - if <context.projectile.has_flag[napalm_flare]>:
            - define num <context.projectile.flag[bounce_number]||0>
            - define velocity <context.projectile.velocity>
            - define location <context.projectile.location.add[<context.hit_face.mul[0.1]>]>
            - if <location[0,0,0,world].distance[<[velocity]>]> < 0.15:
                - inject napalm_flare_events spawn
            - else:
                - determine passively cancelled
                - if <context.hit_face.x> != 0:
                    - define new_velocity:<[velocity].with_x[<[velocity].x.mul[-1]>]>
                - if <context.hit_face.y> != 0:
                    - define new_velocity:<[velocity].with_y[<[velocity].y.mul[-1]>]>
                - if <context.hit_face.z> != 0:
                    - define new_velocity:<[velocity].with_z[<[velocity].z.mul[-1]>]>
                - define new_velocity:<[new_velocity].with_y[<[new_velocity].y.mul[0.35]>].with_x[<[new_velocity].x.mul[0.7]>].with_z[<[new_velocity].z.mul[0.7]>]>
                - spawn snowball <[location]> save:flare
                - define new_flare <entry[flare].spawned_entity>
                - adjust <[new_flare]> velocity:<[new_velocity]>
                - flag <[new_flare]> bounce_number:<[num]>
                - flag <[new_flare]> napalm_flare
                - while <[new_flare].is_spawned>:
                    - playeffect campfire_signal_smoke at:<[new_flare].location> quantity:15 offset:0.2 visibility:100 velocity:<location[<util.random.decimal[-0.1].to[0.1]>,0.3,<util.random.decimal[-0.1].to[0.1]>]>
                    - wait 1t
