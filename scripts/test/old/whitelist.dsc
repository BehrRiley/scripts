whitelist_command:
    type: command
    name: whitelistadd
    usage: /whitelistadd playername
    description: Adds a player to the whitelist
    debug: false
    script:
    - define player <context.args.get[1]||null>
    - if <[player]> == null:
        - stop
    - adjust <[player]> is_whitelisted:true
