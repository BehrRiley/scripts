sidebar_events:
	type: world
    debug: false
    events:
    	on delta time secondly every:4:
        - foreach <server.online_players_flagged[sidebar.visible]> as:target:
          - if !<[target].is_online>:
            - foreach next
          - sidebar set title:<yaml[config].parsed_key[sidebar.title].parse_color> values:<yaml[config].parsed_key[sidebar.lines].parse[parse_color]> player:<[target]>
          - wait 1t

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
    	- if <player.has_flag[sidebar.visible]>:
        	- flag player sidebar.visible:!
            - sidebar remove players:<player>
        - else:
        	- flag player sidebar.visible:true
        	- define lines <yaml[config].parsed_key[sidebar.lines].parse[parse_color]>
        	- sidebar set players:<player> title:<yaml[config].read[sidebar.title].parse_color> values:<[lines]>