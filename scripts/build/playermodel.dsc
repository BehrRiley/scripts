
playermodel_command:
    type: command
    name: playermodel
    debug: false
    definitions: material|custom_model_data
    tab complete:
    - if !<player.has_permission[playermodel]>:
        - stop
    - define index <context.raw_args.split[].count[<&sp>]>
    - define disposed_items <list[]>
    - if <[index]> == 0:
        - if <context.args.get[1].length||0> < 3:
            - determine <list[material]>
        - else:
            - determine <server.list_material_types.parse[name.to_lowercase].filter[starts_with[<context.args.get[1].to_lowercase||>]]>
    - if <[index]> == 1:
        - if <context.args.get[2].length||0> != 0:
            - determine <list[]>
        - else:
            - determine <list[custom_model_data]>
    script:
    - if !<player.has_permission[playermodel]>:
        - narrate "You do not have permission for that command."
        - stop
    - if <context.args.size> == 0:
        - flag <player> playermodel:!
        - fakespawn <player.flag[playermodel].as_entity> cancel
        - narrate "Removed attachment"
    - else if <context.args.size> == 1:
        - narrate "Not enough args"
    - else if <context.args.size> == 2:
        - define material <material[<context.args.get[1]>]||null>
        - if <[material]> == null:
            - narrate "Invalid material"
            - stop
        - define custom_model_data <context.args.get[2]>
        - if <[custom_model_data].div[1]> != <[custom_model_data]>:
            - narrate "Invalid custom model data"
            - stop
        - fakespawn player_model_entity <player.location> save:model players:<server.online_players>
        - define model <entry[model].faked_entity>
        - adjust <[model]> equipment:<item[air]>|<item[air]>|<item[air]>|<item[<[material]>].with[custom_model_data=<[custom_model_data]>]>
        - adjust <player> passengers:<[model]>
        - flag <player> playermodel:<[model]>
        - run playermodel_command path:passive
        - run playermodel_command path:keepalive def:<[material]>|<[custom_model_data]>
    - else:
        - narrate "Too many args"
    passive:
    - while <player.has_flag[playermodel]>:
        - define model <player.flag[playermodel].as_entity>
        - if !<player.is_online> || !<player.has_flag[playermodel]>:
            - fakespawn <[model]> cancel
            - flag <player> playermodel:!
            - while stop
        - wait 1t
        - adjust <player> passengers:<[model]>
    keepalive:
    - while <player.has_flag[playermodel]>:
        - wait 10s
        - if !<player.is_online> || !<player.has_flag[playermodel]>:
            - fakespawn <player.flag[playermodel].as_entity> cancel
            - flag <player> playermodel:!
            - while stop
        - fakespawn player_model_entity <player.location> save:model players:<server.online_players>
        - define model <entry[model].faked_entity>
        - adjust <[model]> equipment:<item[air]>|<item[air]>|<item[air]>|<item[<[material]>].with[custom_model_data=<[custom_model_data]>]>
        - adjust <player> passengers:<[model]>
        - flag <player> playermodel:<[model]>
            
player_model_entity:
    type: entity
    entity_type: armor_stand
    gravity: false
    invulnerable: true
    custom:
        interactable: false
