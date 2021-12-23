flak_cannon_entity:
    type: entity
    entity_type: armor_stand

flak_cannon_item:
    type: item
    material: armor_stand

flak_cartridge:
    type: item
    material: iron_nugget

flak_cannon_inventory:
    type: inventory
    inventory: chest
    title: Flak Cannon
    size: 9
    slots:
    - [] [] [] [] [] [] [] [] []

place_flak_cannon:
    type: task
    debug: false
    definitions: location|player
    script:
        - adjust <queue> linked_player:<[player]||<player>>
        - if <server.plugins.parse[name].contains[Towny]>:
            - narrate 1
        - if <[location]||null> == null:
            - define location <player.location>
        - note <[location]> as:flak_cannon_<[location].simple>

flak_cannon_handler:
    type: world
    debug: false
    config:
        defaults:
            flak_cannon:
                damage: 10
    events:
        on tick:
            - stop
            - foreach <server.online_players> as:p:
                - if <[p].has_flag[old_loc]>:
                    - flag <[p]> vel:<[p].location.sub[<[p].flag[old_loc].as_location>]>
                - flag <[p]> old_loc:<[p].location>
        on delta time secondly:
            - stop
            - foreach <server.notes[inventories].filter[note_name.starts_with[flak_cannon_]]||<list[]>> as:i:
                - define c <[i].note_name.replace_text[flak_cannon_].with[].as_location>
                - if <[c].material||null> == null:
                    - foreach next
                - foreach <[c].find_players_within[64]> as:t:
                    - if <[t].nation.relation[<[c].town.nation>]||null> == allies:
                        - foreach next
                    - if !<[t].location.line_of_sight[<[c]>]>:
                        - foreach next
                    - repeat 100:
                        - define dest <[t].location.add[<[t].flag[vel].as_location.mul[<[value]>]>]>
                        - define dest2 <[c].face[<[dest]>].add[<[dest].sub[<[c]>].div[20].mul[<[value]>]>]>
                        - if <[before]||1000> >= <[dest].points_between[<[dest2]>].distance[0.5].size>:
                            - define before <[dest].points_between[<[dest2]>].distance[0.5].size>
                        - else:
                            - repeat stop
                    - run fire_flak_cannon def:<[c]>|<[dest]>
        on projectile collides with entity:
            - if <context.projectile.has_flag[flak]>:
                - hurt <context.entity> cause:entity_explosion <yaml[config].parsed_key[flak_cannon.damage]||10>
        on entity explodes:
            - if <context.entity.has_flag[flak]>:
                - determine <list[]>

fire_flak_cannon:
    type: task
    debug: false
    definitions: c|dest
    script:
        - ~spawn fireball <[c].face[<[dest]>]> save:e
        - flag <entry[e].spawned_entity> flak
        - adjust <entry[e].spawned_entity> velocity:<[dest].sub[<[c]>].div[20]>
