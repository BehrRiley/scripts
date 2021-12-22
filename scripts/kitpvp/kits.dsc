# kitpvp_events:
#     type: world
#     debug: false
#     events:
#         on block burns:
#         - determine passively cancelled
#         on fire spreads:
#         - determine passively cancelled
#         on server start:
#         - createworld lobby environment:NETHER generator:Terra<&co>LOBBY
#         on player join:
#         - teleport <player> <world[lobby].spawn_location>

kit_gui_handler:
	type: world
    debug: false
    events:
    	on player clicks in kit_gui bukkit_priority:lowest:
		- if <context.item.material.name> == black_stained_glass_pane:
        	- determine cancelled
        - if <context.item.has_flag[kit]>:
        	- determine passively cancelled
            - inventory clear d:<player.inventory>
            - define k <context.item.flag[kit]>
            - foreach <yaml[kits].list_keys[<[k]>.items]> as:e:
                - define item <yaml[kits].parsed_key[<[k]>.items.<[e]>]>
                - inventory set d:<player.inventory> slot:<[e]> o:<[item]>
            - yaml id:arena_instances set player.<player.uuid>.kit:<[k]>

kit_gui:
    type: inventory
    title: <&6>◆ <&a><&n><&l>Kits<&r> <&6>◆
    size: 36
    gui: true
    inventory: chest
    debug: false
    procedural items:
    - foreach <yaml[kits].list_keys[]> as:k:
    	- define item <yaml[kits].read[<[k]>.icon].with[flag=kit:<[k]>]||null>
        - if <[item]> != null:
	        - define items:|:<[item]>
    - determine <[items]>
    definitions:
        w_filler: <item[black_stained_glass_pane].with[display=<&sp>]>
    slots:
    - "[w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler]"
    - "[w_filler] [] [] [] [] [] [] [] [w_filler]"
    - "[w_filler] [] [] [] [] [] [] [] [w_filler]"
    - "[w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler]"
  
kit_command:
    type: command
    name: kit
    debug: false
    tab complete:
    - define index <context.raw_args.split[].count[<&sp>]>
    - if <[index]> == 0:
        - determine <list[get|create|seticon]>
    - if <[index]> == 1:
        - choose <context.args.get[1]>:
            - case create:
                - determine "name of kit"
            - case get:
                - determine <yaml[kits].list_keys[].parse[to_lowercase].filter[starts_with[<context.args.get[2].to_lowercase||>]]>
            - case seticon:
                - determine <yaml[kits].list_keys[].parse[to_lowercase].filter[starts_with[<context.args.get[2].to_lowercase||>]]>
    script:
    - if !<player.has_permission[kit.command]>:
    	- narrate "<&c>You do not have permission for that command."
    	- stop
    - if <context.args.get[1]||null> != null:
    	- if <context.args.get[1]> == seticon:
            - if <context.args.get[2]||null> != null:
                - if <yaml[kits].list_keys[].contains_any[<context.args.get[2]||>]>:
                	- yaml id:kits set <context.args.get[2]>.icon:<player.item_in_hand>
                	- yaml id:kits savefile:data/kits.yml
                    - narrate "<&e>Done."
                - else:
                    - narrate "Kit not found."
        - if <context.args.get[1]> == create:
            - if <context.args.get[2]||null> != null:
                - foreach <player.inventory.map_slots.keys> as:e:
                    - if <player.inventory.map_slots.get[<[e]>].crackshot_weapon||null> != null:
                        - define i:<crackshot.weapon[<player.inventory.map_slots.get[<[e]>].crackshot_weapon>]>
                    - else:
                        - define i:<player.inventory.map_slots.get[<[e]>]>
                    - yaml id:kits set <context.args.get[2]>.items.<[e]>:<[i]>
                - yaml id:kits savefile:data/kits.yml
                - narrate "<&e>Done."
        - else if <context.args.get[1]> == get:
            - if <context.args.get[2]||null> != null:
                - if <yaml[kits].list_keys[].contains_any[<context.args.get[2]||>]>:
                    - inventory clear d:<player.inventory>
                    - foreach <yaml[kits].list_keys[<context.args.get[2]>.items]> as:e:
                        - define item <yaml[kits].parsed_key[<context.args.get[2]>.items.<[e]>]>
                        - inventory set d:<player.inventory> slot:<[e]> o:<[item]>
                    - narrate "<&e>Done."
                - else:
                    - narrate "Kit not found."

kits_config_handler:
    type: world
    debug: false
    reload:
    - if !<server.list_files[data].contains[kits.yml]>:
    	- yaml create id:kits
    - else:
    	- yaml id:kits load:data/kits.yml
    - yaml id:kits savefile:data/kits.yml
    events:
        on reload scripts:
        - inject kits_config_handler path:reload
        on server start:
        - inject kits_config_handler path:reload
