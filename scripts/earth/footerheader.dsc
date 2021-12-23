
footerheader_handle:
    type: world
    debug: false
    events:
        on bungee player joins network:
        - inject refresh_footerheader
        - inject update_footerheader
        on bungee player leaves network:
        - inject refresh_footerheader
        - inject update_footerheader
        on player quits:
        - inject refresh_footerheader
        - inject update_footerheader
        on player joins:
        - inject refresh_footerheader
        - inject update_footerheader
        on server start:
        - wait 10s
        - yaml id:server_info create
        - inject refresh_footerheader
        - inject update_footerheader
        on command:
        - if <context.command.to_lowercase.equals[vanish]>:
            - wait 1s
            - inject refresh_footerheader
            - inject update_footerheader

refresh_footerheader:
    type: task
    debug: false
    script:
    - define players <list[]>
    - if !<yaml.list.contains[server_info]>:
        - yaml id:server_info create
    - foreach <bungee.list_servers||<list[]>>:
        - ~bungeetag server:<[value]> <server.online_players.parse[name]> save:entry
        - define players <[players].include[<entry[entry].result>]>
    - yaml id:server_info set players:<[players]>

update_footerheader:
    type: task
    debug: false
    config:
        defaults:
            footer:
            - something1
            header:
            - something2
    script:
    - wait 1t
    - define header <yaml[config].read[header].parse_tag[<proc[colorize].context[<[parse_value].parsed.parse_color[&].replace[<&pipe>].with[&pipe]>]><&r>].separated_by[<&nl>].unescaped>
    - define footer <yaml[config].read[footer].parse_tag[<proc[colorize].context[<[parse_value].parsed.parse_color[&].replace[<&pipe>].with[&pipe]>]><&r>].separated_by[<&nl>].unescaped>
    - foreach <server.online_players> as:p:
        - adjust <[p]> tab_list_info:<[header]>|<[footer]>
