command_bungeecord:
    type: command
    name: bungeecord
    debug: false
    script:
    - if !<player.has_permission[bungeecord.command]>:
        - narrate "<&c>You do not have permission for that command."
        - stop
    - define cmd <context.alias.to_lowercase.split[<&co>].get[2]||<context.alias.to_lowercase>>
    - define args <context.args||<list[]>>
    - choose <[args].get[1]||>:
        - case parse:
            - define server <[args].get[2]||null>
            - if <[server]> == null:
                - narrate "<&c>Missing server."
                - stop
            - if !<bungee.list_servers.contains[<[server].to_lowercase>]> && <[server].to_lowercase> != all:
                - narrate "<&c>Server not found."
                - stop
            - if <[server]> == all:
                - define server <bungee.list_servers>
            - else:
                - define server <[server].as_list>
            - define tag <[args].get[3]>
            - define player <player>
            - define current <bungee.server>
            - foreach <[server]> as:s:
                - ~bungeetag server:<[s]> <[tag].parsed> save:result
                - define result <entry[result].result>
                - narrate "<&e>Parsed tag on server <&c><[s]> <&e>: <&c><[result]>"
        - case command:
            - define server <[args].get[2]||null>
            - if <[server]> == null:
                - narrate "<&c>Missing server."
                - stop
            - if !<bungee.list_servers.contains[<[server].to_lowercase>]> && <[server].to_lowercase> != all:
                - narrate "<&c>Server not found."
                - stop
            - if <[server]> == all:
                - define server <bungee.list_servers>
            - else:
                - define server <[server].as_list>
            - define command <[args].remove[1].remove[1].space_separated>
            - define player <player.name>
            - define current <bungee.server>
            - foreach <[server]> as:s:
                - bungee <[s]>:
                    - announce to_console "<&c><[player]> <&e>from <&c><[current]> <&e>has executed <&c><&l><[command]>"
                    - execute as_server <[command]>
                - narrate "<&e>Executing command <&c><[command]> <&e>on server <&c><[s]>"

bungeecord_events:
    type: world
    debug: false
    events:
        on server start:
        - yaml id:bungee_logging create
        on console output:
        - stop
        - yaml id:bungee_logging set messages:|:<context.message>
