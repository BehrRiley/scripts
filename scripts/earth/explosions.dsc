explosion_handler:
    type: world
    debug: false
    events:
        on block physics:
        - if <context.location.has_flag[no_physics]>:
            - determine cancelled
        on block falls:
        - if <context.location.has_flag[no_physics]>:
            - determine cancelled
        on block explodes ignorecancelled:true bukkit_priority:lowest:
        - define location <context.block>
        - define blocks <context.blocks>
        - inject explosion_handler path:process_explosion
        on entity explodes ignorecancelled:true bukkit_priority:lowest:
        - define location <context.location>
        - define blocks <context.blocks>
        - inject explosion_handler path:process_explosion
        on entity damaged:
        - if <context.entity.entity_type> == ARMOR_STAND:
            - flag <context.entity> equipment:<context.entity.equipment||<list[]>> duration:5t
            - flag <context.entity> hand:<context.entity.item_in_hand||<item[air]>> duration:5t
            - flag <context.entity> offhand:<context.entity.item_in_offhand||<item[air]>> duration:5t
            - flag <context.entity> pose:<context.entity.armor_pose_map||<list[]>> duration:5t
            - flag <context.entity> has_arms:<context.entity.arms||> duration:5t
        on entity death:
        - ratelimit <context.entity> 1t
        - if <context.cause||null> == ENTITY_EXPLOSION:
            - if <context.entity.entity_type> == ARMOR_STAND:
                - determine passively cancelled
                - define location <context.entity.location>
                - define equipment <context.entity.flag[equipment]>
                - define hand <context.entity.flag[hand]>
                - define offhand <context.entity.flag[offhand]>
                - define pose <context.entity.flag[pose].as_list>
                - define has_arms <context.entity.flag[has_arms]>
                - remove <context.entity>
                - wait <duration[27s]>
                - spawn armor_stand <[location]> save:as
                - define as <entry[as].spawned_entity>
                - adjust <[as]> equipment:<[equipment]>
                - adjust <[as]> item_in_hand:<[hand]>
                - adjust <[as]> item_in_offhand:<[offhand]>
                - adjust <[as]> armor_pose:<[pose]>
                - adjust <[as]> arms:<[has_arms]>
        on entity breaks hanging:
        - if <context.cause> == EXPLOSION:
            # - if <context.hanging.location.is_siege_zone||true>:
            - define location <context.hanging.location>
            - define before <context.hanging.attached_block>
            - define type <context.hanging.entity_type>
            - define rotation <context.hanging.rotation>
            - if <[type]> == ITEM_FRAME || <[type]> == GLOW_ITEM_FRAME:
                - define framed_item <context.hanging.framed_item>
                - define framed_item_rotation <context.hanging.framed_item_rotation>
                - define fixed <context.hanging.fixed>
                - define visible <context.hanging.visible>
                - remove <context.hanging>
                - wait <duration[2s]>
                - spawn <[type]> <[location]> save:e
                - define entity <entry[e].spawned_entity>
                - adjust <[entity]> rotation:<[rotation]>
                - adjust <[entity]> fixed:<[fixed]>
                - adjust <[entity]> visible:<[visible]>
                - adjust <[entity]> framed:<[framed_item]>|<[framed_item_rotation]>
            - else if <[type]> == PAINTING:
                - define painting <context.hanging.painting>
                - define height <context.hanging.painting_height>
                - define width <context.hanging.painting_width>
                - remove <context.hanging>
                - wait <duration[27s]>
                - spawn <[type]> <[location]> save:e
                - define entity <entry[e].spawned_entity>
                - adjust <[entity]> rotation:<[rotation]>
                - adjust <[entity]> painting:<[painting]>
                - define after <[entity].attached_block>
                - if <[before]> != <[after]>:
                    - remove <[entity]>
                    - define location <[location].add[<[before].sub[<[after]>]>]>
                    - spawn <[type]> <[location]> save:e
                    - define entity <entry[e].spawned_entity>
                    - adjust <[entity]> rotation:<[rotation]>
                    - adjust <[entity]> painting:<[painting]>
                    - define after <[entity].attached_block>
    process_explosion:
    #- define new_blocks <[blocks].filter[is_siege_zone.is[==].to[true]||true].filter[has_flag[big_shulker].not]>
    - define new_blocks <[blocks]>
    - if <[new_blocks].size.equals[0]>:
        - stop
    - determine passively <list[]>
    - foreach <[new_blocks].parse[block]> as:b:
        - flag <[b]> no_physics expire:1m
        - define dur <util.random.int[460].to[540]>t
        - define location <[b]>
        - define material <[b].material>
        - foreach <server.online_players.filter[open_inventory.note_name.equals[big_shulker_<[b].block>]]> as:p:
            - inventory close player:<[p]>
        - if <[b].inventory.exists>:
            - define inventory <[b].inventory.map_slots>
            - runlater explosion_handler path:regen_blocks defmap:<map[location=<[location]>;material=<[material]>;inventory=<[inventory]>]> delay:<[dur]>
        - else:
            - runlater explosion_handler path:regen_blocks defmap:<map[location=<[location]>;material=<[material]>]> delay:<[dur]>
        - modifyblock <[b]> air
    regen_blocks:
    - modifyblock <[location]> <[material]>
    - if <[inventory].exists>:
        - foreach <[inventory]> key:slot as:item:
            - inventory set d:<[location].inventory> slot:<[slot]> o:<[item]>