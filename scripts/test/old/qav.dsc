garage_command:
    type: command
    name: garage
    debug: false
    config:
        defaults:
            garage:
                warmup: '&eYou are warming up to open the garage.'
                combat: '&eWarmup failed, You are in combat.'
                moved: '&eWarmup failed, You have moved.'
    script:
    - define location <player.location.block>
    - narrate <proc[colorize].context[<yaml[config].read[garage.warmup]>]>
    - wait 3s
    - if <player.location.block> != <[location]>:
    	- narrate <proc[colorize].context[<yaml[config].read[garage.moved]>]>
    	- stop
    - execute as_player "qav garage rreadyy"

qav_events:
	type: world
    debug: false
    definitions: player|vehicle
    config:
    	playersettings:
        	vehicle:
            	plane:
                	trail: cloud
    glide:
    - if !<player.has_permission[elytra.fun]>:
    	- stop
    - if <[gliding]||<player.gliding>>:
        - playeffect at:<player.location> quantity:50 offset:2 explosion_huge
        - adjust <player> velocity:<player.velocity.add[<player.location.forward[2].sub[<player.location>]>]>
        - flag <player> elytra_fun_queue:<queue.id>
        - wait 1t
        - adjust <player> gliding:true
        - define gauss_val 1
        - define gauss_div 2
        - while <player.gliding> && <player.flag[elytra_fun_queue].equals[<queue.id>]>:
            - define vel <player.velocity.distance[<location[0,0,0,<player.world.name>]>]>
            - if <player.is_sneaking> && <[vel].is_less_than[5]>:
                - adjust <player> velocity:<player.velocity.add[<player.location.forward[0.05].sub[<player.location>]>]>
            - repeat <element[20].mul[<[vel]>]>:
            	- playeffect at:<player.location.add[<location[0,0.5,0]>].sub[<player.velocity.mul[2]>]> quantity:1 offset:2 <player.flag[playersettings.elytra.effect]||cloud> velocity:<player.velocity.face[<location[0,0,0,<player.world.name>]>].mul[-3].relative[<location[<util.random.gauss[<[gauss_val]>].div[<[gauss_div]>]>,<util.random.gauss[<[gauss_val]>].div[<[gauss_div]>]>,0]>]> visibility:500
            - if <player.location.forward[5].material.is_solid>:
                - adjust <player> gliding:false
            - wait 1t
    play_effect:
    - adjust <queue> linked_player:<[player]>
    - wait 1t
    - if !<player.has_permission[trails.vehicle]>:
    	- stop
    - if <[vehicle].qav_type.to_lowercase.ends_with[plane]>:
        - define gauss_val 1
        - define gauss_div 4
    	- while <[vehicle].passengers.contains[<[player]>]||false>:
        	- define vec <[vehicle].velocity.face[<location[0,0,0,<[vehicle].location.world.name>]>]>
        	- define vel <[vehicle].velocity.distance[<location[0,0,0,<[vehicle].location.world.name>]>]>
            - define loc <[vehicle].location.face[<[vehicle].location.add[<[vehicle].velocity>]>]>
        	- if <[vel].is_more_than[0.04]>:
            	- if <[vehicle].qav_name.equals[b2]>:
		    		- playeffect at:<[loc].relative[<location[6,1,-6]>]> quantity:<element[30].mul[<[vel]>]> offset:0.1 <player.flag[playersettings.vehicle.plane.trail]||cloud>
		    		- playeffect at:<[loc].relative[<location[-6,1,-6]>]> quantity:<element[30].mul[<[vel]>]> offset:0.1 <player.flag[playersettings.vehicle.plane.trail]||cloud>
                - else:
                	- repeat <element[100].mul[<[vel]>]>:
	    				- playeffect at:<[loc].relative[<location[0,1,-7]>]> quantity:1 offset:0.5 <player.flag[playersettings.vehicle.plane.trail]||cloud> velocity:<[vec].mul[-3].relative[<location[<util.random.gauss[<[gauss_val]>].div[<[gauss_div]>]>,<util.random.gauss[<[gauss_val]>].div[<[gauss_div]>]>,0]>]> visibility:512
    		- wait 1t
    events:
    	on armor_stand combusts:
        - if <context.entity.qav_type.exists>:
        	- remove <context.entity>
        on player enters qavehicle:
        - ratelimit <player> 1t
        - if <context.vehicle.qav_health||-1> != -1:
        	- run qav_events path:play_effect def:<player>|<context.vehicle>
        on armor_stand spawns:
        - wait 1t
        - if <context.entity.qav_health||-1> != -1 && <context.entity.passengers.get[1].is_player>:
        	- run qav_events path:play_effect def:<context.entity.passengers.get[1]>|<context.entity>
        
qav_garage_events:
	type: world
    debug: false
    events:
    	on command:
        - if <context.command.to_lowercase> == qav || <context.command.to_lowercase> == qualityarmoryvehicles:
        	- if <context.args.get[1]||> == garage && <context.args.get[2]||> != rreadyy:
            	- execute as_player "garage"
                - determine passively cancelled