dynmap_events:
    type: world
    debug: false
    events:
        on delta time secondly:
        - stop
        - foreach <server.online_players.filter[gamemode.equals[survival]]> as:p:
            - if <[p].location.highest.y.is_more_than[<[p].location.y>]>:
                - if <[p].has_flag[above_ground].not>:
                    - execute as_server "dynmap hide <[p].name>"
                    - flag <[p]> above_ground
            - else:
                - if <[p].has_flag[above_ground]>:
                    - execute as_server "dynmap show <[p].name>"
                    - flag <[p]> above_ground:!
