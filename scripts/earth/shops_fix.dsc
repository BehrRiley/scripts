shops_fix:
	type: world
    debug: false
    events:
    	on player right clicks chest ignorecancelled:true bukkit_priority:monitor:
        - if !<context.location.has_town> && <player.has_permission[shop.access.wilderness]>:
        	- determine cancelled:false
        - if <context.location.town.name||1> == <player.town.name||2> && <player.has_permission[shop.access.town]>:
        	- determine cancelled:false
    	on player breaks chest ignorecancelled:true bukkit_priority:monitor:
        - stop
        # this is broken
        - if !<context.location.has_town> && <player.has_permission[shop.access.wilderness]>:
        	- determine cancelled:false
        - if <context.location.town.name||1> == <player.town.name||2> && <player.has_permission[shop.destroy.town]>:
        	- determine cancelled:false