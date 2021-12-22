whitelist_command:
	type: command
    name: whitelistadd
    debug: false
    script:
    - define player <context.args.get[1]||null>
    - if <[player]> == null:
    	- 