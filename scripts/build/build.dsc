build_server_events:
	type: world
    debug: false
    events:
        on block physics adjacent:ladder:
        - determine passively cancelled
command_spawn:
	type: command
    debug: false
    name: spawn
    script:
    - teleport <player> <world[lobby].spawn_location.center.below[0.5]>

command_unwhitelist:
	type: command
    name: openearth
    debug: false
    script:
    - define cuboid <cuboid[lobby,157,98,1298,235,98,1376]>
    - define shapes <list[ball|ball_large|star|burst|creeper]>
    - if <player.has_permission[towny.launch].not>:
    	- narrate "<&c>You do not have permission for that command."
    	- stop
    - define num 20
    - announce "<&c><&l><element[-].repeat[<[num]>]><&nl><&c><&l>GeoPolitical Towny will be launching in 1 minute.<&nl><&c><&l><element[-].repeat[<[num]>]>"
    - wait 30s
    - announce "<&c><&l><element[-].repeat[<[num]>]><&nl><&c><&l>GeoPolitical Towny will be launching in 30 seconds.<&nl><&c><&l><element[-].repeat[<[num]>]>"
    - wait 20s
    - repeat 10:
    	- announce "<&c><&l><[value].mul[-1].add[11]>"
        - title fade_in:0t stay:1s "title:<&c><&l><[value].mul[-1].add[11]>" targets:<server.online_players>
        - playsound <server.online_players> sound:ENTITY_EXPERIENCE_ORB_PICKUP pitch:0
        - wait 1s
    - title fade_in:0t stay:10s "title:<&c><&l>/SERVER EARTH" fade_out:4s targets:<server.online_players>
    - playsound <server.online_players> sound:ENTITY_PLAYER_LEVELUP pitch:0
    - repeat 600:
    	- firework at:<[cuboid].blocks.random> primary:<color[<util.random.int[0].to[255]>,<util.random.int[0].to[255]>,<util.random.int[0].to[255]>]> fade:<color[<util.random.int[0].to[255]>,<util.random.int[0].to[255]>,<util.random.int[0].to[255]>]> trail <[shapes].random>
        - wait 1t