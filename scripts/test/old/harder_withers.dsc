wither_events:
	type: world
    debug: false
    events:
    	on wither spawns:
        - adjust <context.entity> max_health:<context.entity.health.mul[10]>
        - adjust <context.entity> health:<context.entity.health_max>
        - cast INCREASE_DAMAGE amplifier:2 duration:1h <context.entity>
        - while <context.entity.is_spawned||false>:
        	- define players <context.entity.location.find.players.within[10]>
            - repeat 3:
	            - spawn vex <context.entity.location.up[1.5]> save:vex
                - attack <entry[vex].spawned_entity> target:<[players].random||>
        	- wait 5s
        on wither targets vex:
        - determine cancelled
        on vex targets wither:
        - determine cancelled