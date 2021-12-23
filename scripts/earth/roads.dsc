roads_events:
    type: world
    debug: false
    events:
        on player steps on *concrete:
        - ratelimit <player> 1s
        - cast speed duration:2s
