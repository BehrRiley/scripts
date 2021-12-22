elytra_fun:
	type: world
    debug: false
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
            - wait 1t
    events:
    	on player starts sneaking:
        - inject elytra_fun path:glide
        on entity starts gliding:
        - if <player||null> != null:
            - define gliding true
	        - inject elytra_fun path:glide