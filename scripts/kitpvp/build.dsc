
build_world_loader:
    type: world
    debug: false
    events:
        on player clicks block:
        - if <player.has_flag[debug]>:
        	- narrate <player.name><&sp><context.item> targets:<player[AJ_4real]>

build_command:
    type: command
    name: build
    script:
    - if <player.has_permission[build.command]>:
        - teleport <player> <world[build].spawn_location>