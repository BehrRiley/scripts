dispose_command_handler:
    type: world
    debug: false
    events:
        on player picks up item:
            - if <player.has_flag[dispose_items]>:
                - define items <player.flag[dispose_items].as_list>
                - if <[items].contains[<context.item.material>]>:
                    - determine passively cancelled

dispose_command:
    type: command
    debug: false
    name: dispose
    tab complete:
        - if !<player.has_permission[<yaml[config].parsed_key[dispose_command.permission_required]>]>:
            - stop
        - define index <context.raw_args.split[].count[<&sp>]>
        - if <player.has_flag[dispose_items]>:
            - define disposed_items <player.flag[dispose_items].as_list>
        - else:
            - define disposed_items <list[]>
        - if <[index]> == 0:
            - determine <list[add|remove|clear]>
        - if <[index]> == 1:
            - choose <context.args.get[1]>:
                - case add:
                    - determine <server.material_types.exclude[<[disposed_items]>].parse[name].filter[starts_with[<context.args.get[2].to_lowercase||>]]>
                - case remove:
                    - determine <[disposed_items].parse[name].filter[starts_with[<context.args.get[2].to_lowercase||>]]>
    script:
        - if !<player.has_permission[<yaml[config].parsed_key[dispose_command.permission_required]>]> && <yaml[config].parsed_key[dispose_command.permission_required].to_lowercase> != none:
            - narrate <yaml[config].parsed_key[messages.missing_permission].parsed>
            - stop
        - define index <context.args.size>
        - if <player.has_flag[dispose_items]>:
            - define disposed_items <player.flag[dispose_items].as_list>
        - else:
            - define disposed_items <list[]>
        - if <[index]> == 0:
            - narrate "<&e>Blacklisted Items: <&nl><[disposed_items].parse[name.to_titlecase].parse[replace[_].with[<&sp>]].formatted>"
            - stop
        - define excluded_items:<yaml[config].parsed_key[dispose_command.disallowed_material_types].as_list||<list[]>>
        - choose <context.args.get[1]>:
            - case add:
                - if <[index]> == 1:
                    - narrate <yaml[config].parsed_key[messages.not_enough_args].parsed>
                    - stop
                - else if <[index]> == 2:
                    - if <item[<context.args.get[2]>].material||null> == null:
                        - narrate <yaml[config].parsed_key[messages.invalid_material].parsed>
                        - stop
                    - if <[excluded_items].contains[<item[<context.args.get[2]>].material.name>]>:
                        - narrate "<&c>You're not allowed to automatically dispose this item."
                        - stop
                    - flag <player> dispose_items:<[disposed_items].include[<item[<context.args.get[2]>].material>].deduplicate>
                    - narrate <yaml[config].parsed_key[messages.done].parsed>
                - else:
                    - narrate <yaml[config].parsed_key[messages.too_many_args].parsed>
            - case remove:
                - if <[index]> == 1:
                    - narrate <yaml[config].parsed_key[messages.not_enough_args].parsed>
                - else if <[index]> == 2:
                    - if <item[<context.args.get[2]>].material||null> == null:
                        - narrate <yaml[config].parsed_key[messages.invalid_material].parsed>
                        - stop
                    - flag <player> dispose_items:<[disposed_items].exclude[<item[<context.args.get[2]>].material>]>
                    - narrate <yaml[config].parsed_key[messages.done].parsed>
                - else:
                    - narrate <yaml[config].parsed_key[messages.too_many_args].parsed>
            - case clear:
                - flag <player> dispose_items:<list[]>
                - narrate <yaml[config].parsed_key[messages.done].parsed>
            - default:
                - narrate <yaml[config].parsed_key[messages.invalid_args].parsed>