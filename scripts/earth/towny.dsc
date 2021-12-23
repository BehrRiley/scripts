towny_events:
    type: world
    debug: false
    events:
        on resident teleports to town:
        - if <context.destination.town.is_sieged> && <player.town.equals[<context.destination.town>].not||true>:
            - determine cancelled
        on resident teleports to nation:
        - if <context.destination.town.is_sieged> && <player.town.equals[<context.destination.town>].not||true>:
            - determine cancelled
        on command:
        - if <context.args.get[1].to_lowercase.equals[spawn]||false> && <context.args.get[2].exists>:
            - define town <context.args.get[2]||null>
            - if <towny.list_towns.parse[name.to_lowercase].contains[<[town].to_lowercase>].not>:
                - stop
            - define town <town[<[town]>]>
            - if <[town].is_sieged> && <player.has_permission[teleport.to.besieged.town].not>:
                - narrate "<&c>You cannot teleport to a besieged town."
                - determine cancelled
