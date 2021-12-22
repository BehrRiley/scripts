automatic_spark:
	type: world
    debug: false
    events:
    	on delta time secondly every:5:
        - if <paper.tick_times.get[1].is_more_than[2s]>:
	        - narrate targets:<server.online_players.filter[has_permission[spark.auto]]> "<&c><&l>Server Overloaded."
            - execute as_server "spark profiler --stop"
            - wait 1t
            - execute as_server "spark profiler --only-ticks-over 2000"
        