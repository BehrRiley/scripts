siege_zone_stuff:
	type: world
    debug: false
    events:
    	on delta time secondly every:3:
        - foreach <server.online_players.filter[location.is_siege_zone].filter_tag[<[filter_value].location.y.is_more_than[<[filter_value].location.highest.y>]>].filter[location.has_town.not]> as:p:
        	- foreach <[p].location.siege_zone_flag||<list[]>> as:l:
            	- define cuboid <[l].add[<location[15,16,15]>].to_cuboid[<[l].sub[<location[15,16,15]>]>]>
                - if <[cuboid].players.contains[<[p]>]>:
                	- cast <[p]> glowing duration:4s