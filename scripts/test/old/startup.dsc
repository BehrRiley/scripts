
startup_handler:
    type: world
    debug: false
    events:
        on server start bukkit_priority:monitor:
        - foreach <yaml[config].read[startup_commands]>:
            - execute as_server <[value]>
