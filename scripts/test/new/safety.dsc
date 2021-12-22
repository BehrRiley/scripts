safety_events:
	type: world
    debug: false
    events:
    	on delta time secondly:
        - if <server.ram_allocated.sub[<server.ram_free>].div[<server.ram_allocated>].is_more_than[0.95].or[<server.recent_tps.get[1].is_less_than[5]>]> || <server.has_flag[safety_override]>:
        	- if <server.has_flag[safety].not>:
            	- announce "<&c><&l>Primary thread is overloaded. Culling processes... Possible restart imminent."
                - flag server safety
                - define mobs <server.worlds.parse[entities].combine>
                - foreach <[mobs]>:
                	- adjust <[value]> has_ai:false
                - wait 10s
                - if <server.ram_allocated.sub[<server.ram_free>].div[<server.ram_allocated>].is_more_than[0.95]> && <server.recent_tps.get[1].is_less_than[5]>:
                    - announce "<&c><&l>Restarting..."
                	- execute as_server "spark heapdump"
                    - wait 2s
                    - execute as_server "stop"
        - else:
        	- if <server.has_flag[safety]>:
            	- announce "<&c>Server safety disabled."
            	- flag server safety:!
                - define mobs <server.worlds.parse[entities].combine>
                - foreach <[mobs]>:
                	- adjust <[value]> has_ai:true
        on shutdown:
        - foreach <server.players.filter[has_flag[combat]].include[<server.players.filter[has_flag[]]]>:
        	- flag <[value]> combat:!
        on redstone recalculated server_flagged:safety:
        - determine cancelled
        on entity spawns server_flagged:safety:
        - determine cancelled
        on block falls server_flagged:safety:
        - determine cancelled
        on block physics server_flagged:safety:
        - determine cancelled
command_safety:
	type: command
    name: safety
    debug: false
    script:
    - if <player.has_permission[orbis.safety].not>:
    	- narrate "<&c>You do not have permission for that command."
    	- stop
    - if <server.has_flag[safety_override]>:
	    - flag server safety_override:!
    - else:
    	- flag server safety_override