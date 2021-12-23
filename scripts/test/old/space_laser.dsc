space_laser_item:
    type: item
    material: firework_rocket
    display name: <&r><&c>Orbital Strike
    recipes:
        1:
            type: shapeless
            input: blaze_powder|blaze_powder|gunpowder|fire_charge|fire_charge|lava_bucket

space_laser_handler:
    type: world
    debug: false
    config:
        defaults:
            space_laser:
                enabled: true
                enable_recipe: false
                explosive_power: 50
                fire_explosive: true
                explosion_breaks_blocks: true
                duration: 200
    events:
        on reload scripts:
        - if !<yaml[config].parsed_key[space_laser.enable_recipe]>:
            - adjust server remove_recipes:<item[space_laser_item].recipe_ids>

space_laser_flare_item:
    type: item
    material: snowball
    display name: Flare

space_laser_run:
    type: task
    definitions: location
    debug: false
    script:
    - define location <[location].block||<[location]>>
    - define lowest <[location].highest>
    - define points1 <[location].with_y[<[lowest].y>].points_between[<[location].with_y[260]>].distance[1]>
    - repeat <[points1].size.div[3]>:
        - playeffect crit_magic at:<[points1].filter[y.is_more_than[<[location].highest.y>]].random[<[value]>]> visibility:500 quantity:10 offset:2 velocity:<location[0,-5,0]>
        - wait 1t
    - define explode <[location].with_y[1].points_between[<[location].with_y[255]>].distance[4]>
    - define fire <yaml[config].parsed_key[space_laser.fire_explosive]||true>
    - define break <yaml[config].parsed_key[space_laser.explosion_breaks_blocks]||false>
    - define ex <[explode].filter[y.is_more_than[<[location].highest.y>]].random[2].include[<[location].highest>].parse[add[<location[<util.random.int[-1].to[1]>,0,<util.random.int[-1].to[1]>]>]]>
    - repeat <yaml[config].read[space_laser.duration]||20>:
        - playeffect flash at:<[points1]> visibility:300 quantity:1 offset:0 velocity:<location[0,-1,0]>
        - if <[lowest]> != <[location].highest>:
            - define lowest <[location].highest>
            #- define ex <[explode].filter[y.is_more_than[<[lowest].y>]].random[2].include[<[location].highest>].parse[add[<location[<util.random.int[-1].to[1]>,0,<util.random.int[-1].to[1]>]>]]>
        - define p <[location].highest.up[2]>
        - if <[fire]>:
            - if <[break]>:
                - explode <[p]> power:<yaml[config].parsed_key[space_laser.explosive_power]||1> fire breakblocks
            - else:
                - explode <[p]> power:<yaml[config].parsed_key[space_laser.explosive_power]||1> fire
        - else:
            - if <[break]>:
                - explode <[p]> power:<yaml[config].parsed_key[space_laser.explosive_power]||1> breakblocks
            - else:
                - explode <[p]> power:<yaml[config].parsed_key[space_laser.explosive_power]||1>
        - wait 2t

space_laser_flare_events:
    type: world
    debug: false
    events:
        on player clicks block:
        - if <player.item_in_hand.script.name.equals[space_laser_item]||false>:
            - define location <player.location>
            - announce "<player.name> has called in an orbital strike at <[location].block.x>, <[location].block.z>"
            - take from:<player.inventory> item:space_laser_item
            - inject space_laser_run
