travel_command:
    type: command
    debug: false
    name: travel
    tab complete:
        - if !<player.has_permission[travel.command]>:
            - stop
        - define index <context.raw_args.to_list.count[<&sp>]>
        - if <[index]> == 0:
            - determine <server.list_files[../../].filter[starts_with[template_]].parse.replace_text[template_].with[]].filter[starts_with[<context.args.get[1]||>]]>
    script:
    - define world <context.args.get[0]||null>
    - if <[world]> != null && <world[template_<[world]>]||null> != null:
        - define world <world[template_<[world]>]>
        - teleport <player> <[world].spawn_location>
