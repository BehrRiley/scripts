
melon_blocks_sticky_piston:
    type: world
    debug: false
    events:
        on piston extends:
            - if <context.material.name> == sticky_piston:
                - foreach <context.blocks> as:l:
                    - if <[l].material.name> == melon:
                        - adjust <[l]> block_type:air
                        - drop <[l].center> melon