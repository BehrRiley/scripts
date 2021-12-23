
build_world_loader:
    type: world
    debug: false
    events:
        on entity prespawns:
            - if <context.location.world.name> == build:
                - determine cancelled
            - if <context.location.world.name.starts_with[template_]> || <context.location.world.name.starts_with[arena_instance_]>:
                - determine cancelled

build_command:
    type: command
    usage: /build
    description: Teleports you to the Build spawn
    name: build
    script:
        - teleport <player> <world[build].spawn_location>
