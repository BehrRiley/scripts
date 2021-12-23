
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
        after server starts:
        - yaml id:server_info create
        - wait 10s
        - inject update_footerheader

refresh_footerheader:
    type: task
    debug: false
    script:
    - define players <list[]>
    - foreach <bungee.list_servers>:
        - ~bungeetag server:<[value]> <server.online_players.parse[name]> save:entry
        - define players <[players].include[<entry[entry].result>]>
    - yaml id:server_info set players:<[players]>

update_footerheader:
    type: task
    debug: false
    script:
    - wait 1t
    - define line1 "<&3>Welcome To <&c><&l>Kit-PvP"
    - define line2 "<&b>Online <&r><yaml[server_info].read[players].as_list.size||0> / 200"
    - define line3 "<&r><server.online_players.filter[cmi_vanish.not].size> / <server.max_players>"
    - define header <list[<[line1]>|<[line2]>|<[line3]>].separated_by[<&nl>]>
    - define line4 "<&l><&b>Website <&r>www.orbismc.com"
    - define line5 "<&l><&3>Store <&r>https://store.orbismc.com"
    - define footer <list[<[line4]>|<[line5]>].separated_by[<&nl>]>
    - foreach <server.online_players> as:p:
        - adjust <[p]> tab_list_info:<[header]>|<[footer]>
