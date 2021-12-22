auto_restart_events:
	type: world
    debug: false
    restart:
    - title "title:<&c>Restart Imminent" "subtitle:Server restarting in 5 minutes." targets:<server.online_players>
    - wait 1m
    - title "title:<&c>Restart Imminent" "subtitle:Server restarting in 4 minutes." targets:<server.online_players>
    - wait 1m
    - title "title:<&c>Restart Imminent" "subtitle:Server restarting in 3 minutes." targets:<server.online_players>
    - wait 1m
    - title "title:<&c>Restart Imminent" "subtitle:Server restarting in 2 minutes." targets:<server.online_players>
    - wait 1m
    - title "title:<&c>Restart Imminent" "subtitle:Server restarting in 1 minutes." targets:<server.online_players>
    - wait 50s
    - repeat 11:
    	- title "title:<&c>Restart Imminent" "subtitle:Server restarting in <[value].sub[10].mul[-1].add[1]>." targets:<server.online_players>
        - wait 1s
    - execute as_server "restart"
    events:
    	on system time 06:55:
        - inject auto_restart_events path:restart