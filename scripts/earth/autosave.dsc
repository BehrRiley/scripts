autosave_events:
	type: world
    debug: false
    events:
    	on delta time minutely every:30:
        - stop
        - announce "<&c><&l>Saving in 10 seconds..."
        - wait 10s
        - announce "<&c><&l>Saving Server..."
        - execute as_server "save-all"
        - adjust server save