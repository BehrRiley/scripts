sidebar_events:
    type: world
    debug: false
    events:
        on delta time secondly:
        - foreach <server.online_players.filter_tag[<[filter_value].flag[sidebar.visible].and[<[filter_value].has_flag[staffmode].not>]||true>]> as:player:
            - define lines <yaml[config].read[sidebar.lines].parse[parsed].parse_tag[<proc[colorize].context[<[parse_value]>|<[player]>|null]>]>
            - sidebar set players:<[player]> title:<proc[colorize].context[<yaml[config].read[sidebar.title]>|<[player]>|null]> values:<[lines]>
command_sidebar:
    type: command
    name: sidebar
    debug: false
    aliases:
    - sb
    tab complete:
    - determine <list[toggle].filter[to_lowercase.starts_with[<context.args.get[1].to_lowercase||>]]>
    script:
    - if <context.args.get[1]||> == toggle:
        - define player <player>
        - if <player.flag[sidebar.visible]||false>:
            - flag <player> sidebar.visible:false
            - sidebar remove players:<player>
        - else:
            - flag <player> sidebar.visible:true
            - define lines <yaml[config].read[sidebar.lines].parse[parsed].parse_tag[<proc[colorize].context[<[parse_value]>|<[player]>|null]>]>
            - sidebar set players:<[player]> title:<proc[colorize].context[<yaml[config].read[sidebar.title]>|<[player]>|null]> values:<[lines]>
