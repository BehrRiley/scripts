

command_transfer_cuboid:
    type: command
    debug: false
    name: transfercuboid
    script:
    - if <player.has_permission[transfercuboid.command].not>
        - narrate "<&c>You do not have permission for that command."
        - stop
    - define cuboid <player.we_selection||null>
    - if <[cuboid].equals[null]>:
        - narrate "<&c>Invalid Selection"
        - stop
    - ~bungeetag server:lobby <server.worlds.parse[name]> save:worlds
    - define worlds <entry[worlds].result>
    - if <[worlds].contains[<[cuboid].world.name>].not>:
        - narrate "<&c>This world does not exist in hub"
        - stop
    - define blocks <map[]>
    - define entities <map[]>
    - define signs <map[]>
    - foreach <[cuboid].blocks> as:b:
        - define blocks <[blocks].with[<[b]>].as[<[b].material>]>
        - if <[b].sign_contents.exists>:
            - define signs <[signs].with[<[b]>].as[<[b].sign_contents>]>
    - foreach <[cuboid].entities.filter[is_player.not]> as:b:
        - define entities <[entities].with[<[b].location>].as[<[b].describe>]>
    - ~bungee lobby:
        - foreach <[cuboid].chunks>:
            - chunkload <[value]> duration:5m
        - wait 2t
        - foreach <[blocks].keys> as:b:
            - modifyblock <[b]> <[blocks].get[<[b]>]>
            - if <[signs].contains[<[b]>]>:
                - adjust <[b]> sign_contents:<[signs].get[<[b]>]>
        - remove <[cuboid].entities.filter[is_player.not]>
        - foreach <[entities].keys> as:k:
            - spawn <[entities].get[<[k]>]> <[k]>
