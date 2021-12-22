curing_pillagers_events:
	type: world
    debug: false
    events:
    	on player right clicks pillager:
        - if <context.item.material.name.equals[enchanted_golden_apple].not>:
        	- stop
        - ratelimit <context.entity>_<player> 1t
        - announce <context.entity.item_in_hand>
        on pillager damaged by freeze:
        - if <context.entity.has_flag[curing]>:
	        - determine cancelled