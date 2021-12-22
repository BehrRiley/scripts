max_stack_size_events:
	type: world
    debug: false
    events:
    	on server start:
        - adjust <material[cobweb]> max_stack_size:8
        after player clicks in inventory:
        - if <player.gamemode.equals[survival]>:
	        - inventory update