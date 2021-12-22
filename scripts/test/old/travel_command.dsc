travel_command:
    type: command
    debug: false
    name: travel
    tab complete:
    - determine <yaml[earth_map].list_keys[earth].filter[to_lowercase.starts_with[<context.args.get[1].to_lowercase||>]]>
    script:
    - if <context.source_type> != PLAYER:
    	- narrate "<&c>This command can only be executed by a player."
        - stop
    - if <context.args.get[1]||> == set && <context.args.get[2]||null> != null && <context.args.get[3]||null> != null:
    	- if !<player.has_permission[travel.command.set]>:
    		- narrate "<&c>You do not have permission for that command."
    		- stop
		- yaml id:earth_map set earth.<context.args.get[2]>.<context.args.get[3]>:<player.location>
        - narrate "set point <context.args.get[3]> of <context.args.get[2]> to <player.location.simple.formatted>"
        - inject travel_events path:save
        - stop
    - if <context.args.get[1]||null> != null:
    	- if !<yaml[earth_map].list_keys[earth].contains[<context.args.get[1]>]>:
        	- narrate "<&c>Location not found."
        	- stop
        - if <player.has_flag[no_travel_command]>:
        	- narrate "<&c>You cannot use this command for <player.flag_expiration[no_travel_command].from_now.formatted>."
            - stop
        - define continent <context.args.get[1]>
        - inject get_random_point_task
        - teleport <[loc]>
        - flag <player> no_travel_command duration:5m
        - flag <player> no_fall duration:1m
        - waituntil <player.location.below[0.01].material.is_solid||false>
        - wait 1s
        - flag <player> no_fall:!

get_random_point_task:
	type: procedure
    debug: false
    definitions: continent
    script:
    - define continent <[continent]||<yaml[earth_map].list_keys[earth].random>>
    - define world <yaml[earth_map].read[earth.<[continent]>.<yaml[earth_map].list_keys[earth.<[continent]>].first>].world.name>
    - define x_range <yaml[earth_map].list_keys[earth.<[continent]>].parse_tag[<yaml[earth_map].read[earth.<[continent]>.<[parse_value]>]>].parse[block.x]>
    - define z_range <yaml[earth_map].list_keys[earth.<[continent]>].parse_tag[<yaml[earth_map].read[earth.<[continent]>.<[parse_value]>]>].parse[block.z]>
    - define x <util.random.int[<[x_range].lowest>].to[<[x_range].highest>]>
    - define z <util.random.int[<[z_range].lowest>].to[<[z_range].highest>]>
    - define poly <polygon[<[world]>,254,255]>
    - foreach <yaml[earth_map].list_keys[earth.<[continent]>]> as:k:
        - define poly <[poly].with_corner[<yaml[earth_map].read[earth.<[continent]>.<[k]>]>]>
    - define l <location[<util.random.int[<[x_range].lowest>].to[<[x_range].highest>]>,254,<util.random.int[<[z_range].lowest>].to[<[z_range].highest>]>,<[world]>]>
    - while !<[poly].contains[<[l]>]>:
    	- define l <location[<util.random.int[<[x_range].lowest>].to[<[x_range].highest>]>,254,<util.random.int[<[z_range].lowest>].to[<[z_range].highest>]>,<[world]>]>
        - wait 1t
    - chunkload <[l].chunk> duration:30s
    - waituntil <[l].chunk.is_loaded>
    - define loc <[l].highest.up[1]>

get_random_point:
	type: procedure
    debug: false
    definitions: continent
    script:
    - define continent <[continent]||<yaml[earth_map].list_keys[earth].random>>
    - define world <yaml[earth_map].read[earth.<[continent]>.<yaml[earth_map].list_keys[earth.<[continent]>].first>].world.name>
    - define x_range <yaml[earth_map].list_keys[earth.<[continent]>].parse_tag[<yaml[earth_map].read[earth.<[continent]>.<[parse_value]>]>].parse[block.x]>
    - define z_range <yaml[earth_map].list_keys[earth.<[continent]>].parse_tag[<yaml[earth_map].read[earth.<[continent]>.<[parse_value]>]>].parse[block.z]>
    - define x <util.random.int[<[x_range].lowest>].to[<[x_range].highest>]>
    - define z <util.random.int[<[z_range].lowest>].to[<[z_range].highest>]>
    - define poly <polygon[<[world]>,254,255]>
    - foreach <yaml[earth_map].list_keys[earth.<[continent]>]> as:k:
        - define poly <[poly].with_corner[<yaml[earth_map].read[earth.<[continent]>.<[k]>]>]>
    - define l <location[<util.random.int[<[x_range].lowest>].to[<[x_range].highest>]>,254,<util.random.int[<[z_range].lowest>].to[<[z_range].highest>]>,<[world]>]>
    - while !<[poly].contains[<[l]>]>:
    	- define l <location[<util.random.int[<[x_range].lowest>].to[<[x_range].highest>]>,254,<util.random.int[<[z_range].lowest>].to[<[z_range].highest>]>,<[world]>]>
        - define i <[i].add[1]||1>
        - if <[i].is_more_than[50]>:
        	- stop
    - determine <[l]>

travel_events:
	type: world
    debug: false
    save:
    - yaml id:earth_map savefile:data/earth_map.yml
    load:
    - if <server.list_files[data].contains[earth_map.yml]>:
        - yaml id:earth_map load:data/earth_map.yml
    - else:
        - yaml id:earth_map create
    events:
    	on player death:
        - define location <player.location>
        - wait 1t
        - adjust <player> respawn
        - inject get_random_point_task
        - teleport <player> <[loc]>
        - inventory clear d:<player.inventory>
        - adjust <player> health:20
        - adjust <player> food_level:20
        - flag <player> no_fall duration:1m
        - waituntil <player.location.below[0.01].material.is_solid||false>
        - wait 1s
        - flag <player> no_fall:!
    	on server start:
        - inject travel_events path:load
        on reload scripts:
        - inject travel_events path:load
        on shutdown:
        - inject travel_events path:save