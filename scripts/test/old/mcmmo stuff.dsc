timed_perks_events:
	type: world
    debug: false
    events:
    	on mcmmo player gains xp for skill:
        - if <server.has_flag[boosts.mcmmo.xp_multiplier]>:
        	- determine <context.xp.mul[<server.flag[boosts.mcmmo.xp_multiplier]>]||<context.xp>>

perks_command:
	type: command
    name: perk
    debug: false
    script:
    - if <context.source_type.to_lowercase.equals[server].not>:
    	- narrate "<&c>This command can only be executed from console."
    	- stop
    - choose <context.args.get[1].to_lowercase||>:
    	- case "mcmmo_xp_boost":
        	- if <context.args.get[2].is_decimal.not||true>:
            	- stop
            - define mul <context.args.get[2]>
            - define dur <context.args.get[3].as_duration||<duration[1h]>>
            - define duration <server.flag_expiration[boosts.mcmmo.xp_multiplier].from_now.add[<[dur]>]||<[dur]>>
            - announce "<&e>MCMMO <[mul]>x multiplier activated for <[duration].formatted_words>"
            - flag server boosts.mcmmo.xp_multiplier:<[mul]> duration:<[duration]>