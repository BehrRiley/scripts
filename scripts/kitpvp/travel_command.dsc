travel_command:
    type: command
    debug: false
    name: travel
    tab complete:
    - if !<player.has_permission[travel.command]>:
        - stop
    - if <yaml[arena_instances].read[player.<player.uuid>]||null> != null:
        - narrate "<&c>You cannot travel while in a fight."
        - stop
    - define index <context.raw_args.to_list.count[<&sp>]>
    - if <[index]> == 0:
        - determine <server.list_files[../../].filter[starts_with[template_]].parse.replace_text[template_].with[]].filter[starts_with[<context.args.get[1]||>]]>
    script:
    - if !<player.has_permission[travel.command]>:
        - stop
    - define world <context.args.get[0]||null>
    - if <[world]> != null && <world[template_<[world]>]||null> != null:
        - define world <world[template_<[world]>]>
        - teleport <player> <[world].spawn_location>
        - adjust <player> gamemode:creative
