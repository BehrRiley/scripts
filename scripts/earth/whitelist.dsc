whitelist_command:
    type: command
    name: whitelistadd
    description: whitelists a player
    usage: /whitelistadd playername
    debug: false
    script:
    - define player <context.args.get[1]||null>
    - if <[player]> == null:
        - stop
    - adjust <[player]> is_whitelisted:true
