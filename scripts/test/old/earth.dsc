earth_events:
	type: world
    debug: false
    events:
        on delta time minutely every:5:
        - define msg <yaml[config].read[announcements.messages.<yaml[config].list_keys[announcements.messages].random>].parse[parsed].parse_tag[<proc[colorize].context[<[parse_value]>]>].separated_by[<&nl>]>
        - narrate <[msg]> targets:<server.online_players>
        on player joins:
        - if <player.has_flag[joined]>:
	        - define msg <yaml[config].read[announcements.on<&sp>join].parse_tag[<proc[colorize].context[<[parse_value]>].parsed>].separated_by[<&nl>]>
    	    - narrate <[msg]>
        - else:
        	- define msg <yaml[config].read[announcements.on<&sp>first<&sp>join].parse_tag[<proc[colorize].context[<[parse_value]>].parsed>].separated_by[<&nl>]>
        	- narrate <[msg]>
            - flag <player> joined