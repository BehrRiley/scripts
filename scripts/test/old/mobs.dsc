mob_drops_events:
    type: world
    debug: false
    events:
        on wither_skeleton dies:
        - determine <context.drops.include[<item[gunpowder].with[quantity=<util.random.int[1].to[4]>]>]>
