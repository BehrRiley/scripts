missions_events:
    type: world
    debug: false
    reload:
    - if !<server.list_files[data].contains[missions.yml]>:
        - yaml create id:missions
    - else:
        - yaml id:missions load:data/missions.yml
    - yaml id:missions savefile:data/missions.yml
    events:
        on reload scripts:
        - inject missions_events path:reload
        on server start:
        - inject missions_events path:reload
        on entity killed:
        - if <context.damager.is_player||false>:
            - define player <context.damager>
            - ratelimit 2s <context.entity>
            - define task kill_entity
            - define context <context.entity.entity_type>
            - define amount 1
            - inject process_mission
        on entity breeds:
        - if <context.breeder.is_player||false>:
            - define player <context.breeder>
            - define task breed_entity
            - define context  <context.child.entity_type>
            - define amount 1
            - inject process_mission
        on portal created:
        - if <context.entity.is_player||false>:
            - define player <context.entity>
            - define task create_portal
            - define context null
            - define amount 1
            - inject process_mission
        on entity tamed:
        - if <context.owner.is_player||false>:
            - define player <context.owner>
            - define task tame_entity
            - define context <context.entity.entity_type>
            - define amount 1
            - inject process_mission
#        on player opens inventory:
#        - define list <list[BREWING|FURNACE]>
#        - if !<[list].contains_any[<context.inventory.inventory_type>]>:
#            - stop
#        - if <context.inventory.location||null> != null:
#            - define location <context.inventory.location.block>
#            - note <[location]> as:<context.inventory.inventory_type>_<[location].simple>_<player>
#            - wait 5m
#            - note remove as:<context.inventory.inventory_type>_<[location].simple>_<player>
        on player breaks block:
        - if <context.material.name> == furnace:
            - note remove as:<context.location.block.note_name>
        on brewing stand brews:
        - if <context.location.note_name||null> != null:
            - foreach <list[1|2|3]> as:i:
                - define player <context.location.note_name.split[_].get[3].as_player>
                - define task brew_potion
                - define context <context.inventory.slot[<[i]>]>
                - define amount 1
                - inject process_mission
        on furnace burns item:
        - if <context.location.note_name||null> != null:
            - define player <context.location.note_name.split[_].get[3].as_player>
            - define task burn_fuel
            - define context <context.item>
            - define amount 1
            - inject process_mission
        on player crafts item:
        - define player <player>
        - define task craft_item
        - define context <context.item.material.name>
        - define amount <context.amount>
        - if <context.click_type.to_lowercase.equals[shift_right]>:
            - narrate "<&c>You cannot shift right click items out of a crafting grid."
            - determine cancelled
        - inject process_mission
        on player breaks block:
        - define player <player>
        - define task break_block
        - define context <context.material.name>
        - define amount 1
        - inject process_mission
        on player places block:
        - define player <player>
        - define task place_block
        - define context <context.material.name>
        - define amount 1
        - inject process_mission
        on player right clicks sheep:
        - ratelimit <player> 1t
        - define old <context.entity.color>
        - wait 1t
        - define new <context.entity.color>
        - if <[old]> != <[new]>:
            - define player <player>
            - define task dye_sheep
            - define context <[new]>
            - define amount 1
            - inject process_mission
        on item enchanted:
        - if <context.entity.is_player>:
            - define player <context.entity>
            - define task enchant_item
            - define context <context.item.material.name.replace_text[golden_].with[gold_]>
            - define amount 1
            - inject process_mission
        on player breaks held item:
        - define player <player>
        - define task break_item
        - define context <context.item.material.name>
        - define amount 1
        - inject process_mission
        on player changes xp:
        - if <context.amount.is_more_than[0]>:
            - define player <player>
            - define task gain_xp
            - define context null
            - define amount <context.amount>
            - inject process_mission
        on player consumes item:
        - define player <player>
        - define task consume_item
        - define context <context.item.material.name>
        - define amount 1
        - inject process_mission
        on player fills bucket:
        - define player <player>
        - define task fill_bucket
        - define context <context.item.material.name>
        - define amount 1
        - inject process_mission
        on player fishes:
        - define player <player>
        - define task fish_item
        - define context <context.item.material.name||null>
        - if <[context].equals[leather]>:
            - define context salmon
        - define amount <context.item.quantity||1>
        - if <[context].equals[null]>:
            - stop
        - inject process_mission
        on player shears sheep:
        - define player <player>
        - define task shear_sheep
        - define context <context.entity.color>
        - define amount 1
        - inject process_mission
        on player clicks cake:
        - define old <context.location.material.level>
        - wait 1t
        - define new <context.location.material.level||-1>
        - if <[old]> != <[new]>:
            - define player <player>
            - define task consume_item
            - define context cake
            - define amount 1
            - inject process_mission
        on crackshot player fires projectile:
        - define player <player>
        - define task fire_weapon
        - define context <context.weapon>
        - define amount 1
        - inject process_mission
        on crackshot player finishes reloading weapon:
        - define player <player>
        - define task reload_weapon
        - define context <context.weapon>
        - define amount 1
        - inject process_mission
        on crackshot weapon damages entity:
        - define player <player>
        - define task deal_damage_with_gun
        - define context <context.weapon>
        - define amount <context.damage>
        - inject process_mission

        on player clicks block:
        - if <context.item.script.name||> != mission_item:
            - stop
        - define req <context.item.flag[requirement]>
        - define prog <context.item.flag[progress]>
        - if <[req].is_less_than_or_equal_to[<[prog]>]>:
            - define item <context.item>
            - define tier <[item].flag[tier]>
            - if <player.inventory.slot[<player.held_item_slot>]> != <context.item>:
                - stop
            - foreach <yaml[missions].read[missions.rewards.<[tier]>]> as:cmd:
                - execute as_server <[cmd].replace[<&pc>player_name<&pc>].with[<player.name>]>
            - narrate "<&e>You have completed a <[item].display>"
            - title "title:<&e>Mission Complete!" "subtitle:You have completed a <[item].display>"
            - inventory set d:<player.inventory> slot:<player.held_item_slot> o:<item[air]>

get_mission_item:
    type: procedure
    debug: false
    definitions: tier|type
    script:
    - define item <item[mission_item]>
    - if <[type].exists.not>:
        - foreach <yaml[missions].list_keys[missions.requirements]> as:t:
            - repeat <yaml[missions].read[missions.weights.types.<[t]>]||1>:
                - define type_options:|:<[t]>
        - define type <[type_options].random>
    - define context <yaml[missions].list_keys[missions.requirements.<[type]>].random||null>
    - foreach <yaml[missions].list_keys[missions.weights.tiers]> as:t:
        - repeat <yaml[missions].read[missions.weights.tiers.<[t]>]||1>:
            - define tier_options:|:<[t]>
    - define tier <[tier]||<[tier_options].random>>
    - if <[tier].exists.not>:
        - foreach <yaml[missions].list_keys[missions.requirements.<[type]>.<[context]>]> as:k:
            - define tier_options:|:<[k].repeat_as_list[<yaml[missions].read[missions.weights.tiers.<[k]>]>]>
        - define tier <[tier_options].random>
    - if <[type]> == gain_xp:
        - define min <yaml[missions].read[missions.requirements.<[type]>.<[tier]>.min]>
        - define max <yaml[missions].read[missions.requirements.<[type]>.<[tier]>.max]>
    - else:
        - define context <yaml[missions].list_keys[missions.requirements.<[type]>].random[1].get[1]||null>
        - define min <yaml[missions].read[missions.requirements.<[type]>.<[context]>.<[tier]>.min]>
        - define max <yaml[missions].read[missions.requirements.<[type]>.<[context]>.<[tier]>.max]>
    - if <util.random.int[<[min]>].to[<[max]>]||null> == null:
        - determine <proc[get_mission_item].context[<[tier]>]>
    - define item <[item].with[display=<proc[colorize].context[<yaml[missions].read[missions.strings.tiers.<[tier]>]>]>]>
    - define item <[item].with[flag=type:<[type]>]>
    - define item <[item].with[flag=context:<[context]>]>
    - define item <[item].with[flag=tier:<[tier]>]>
    - define item <[item].with[flag=requirement:<util.random.int[<[min]>].to[<[max]>]>]>
    - define item <[item].with[flag=progress:0]>
    - define item <[item].with[flag=uuid:<util.random.uuid>]>
    - determine <proc[build_mission_lore].context[<[item]>]>

build_mission_lore:
    type: procedure
    definitions: item
    debug: false
    script:
    - define lore <list[<yaml[missions].read[missions.strings.objective]>]>
    - define lore <[lore].include[<yaml[missions].read[missions.strings.types.<[item].flag[type]>.titlecase].replace[<&pc>context<&pc>].with[<[item].flag[context]>].replace_text[_].with[<&sp>]>]>
    - define lore <[lore].include[<yaml[missions].read[missions.strings.types.<[item].flag[type]>.base].replace[<&pc>current<&pc>].with[<[item].flag[progress]>].replace[<&pc>requirement<&pc>].with[<[item].flag[requirement]>]>]>
    - define item <[item].with[lore=<[lore].parse_tag[<proc[colorize].context[<&f><[parse_value]>]>]>]>
    - determine <[item]>

process_mission:
    type: task
    debug: false
    definitions: player|task|context|amount
    script:
    - if <[player].inventory.contains_item[mission_item]>:
        - adjust <queue> linked_player:<[player]>
        - foreach <[player].inventory.map_slots.keys||<list[]>> as:s:
            - define item <[player].inventory.slot[<[s]>]>
            - if <[item].script.name||null> != mission_item:
                - foreach next
            - if <[item].flag[context]||> != <[context]> && <[item].flag[type]||> != gain_xp:
                - foreach next
            - if <[item].flag[type]||> != <[task]>:
                - foreach next
            - if <[item].flag[progress].add[1].is_more_than[<[item].flag[requirement]>]>:
                - foreach next
            - define item <[item].with[flag=progress:<[item].flag[progress].add[<[amount]>]>]>
            - define item <proc[build_mission_lore].context[<[item]>]>
            - if <[item].flag[requirement]> == <[item].flag[progress]>:
                - narrate "<&e>Mission has reached its goal." targets:<player>
                - flag <[player]> missions.completed:+:1
                - define i <[player].flag[missions.completed]>
                #- townymeta <[player]> key:missions.completed "label:Missions Completed" value:<[i]>
            - inventory set d:<player.inventory> slot:<[s]> o:<[item]>

mission_item:
    type: item
    material: paper
