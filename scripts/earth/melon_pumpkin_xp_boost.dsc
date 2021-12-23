melon_pumpkin_xp_boost_events:
    type: world
    debug: false
    events:
        on player breaks pumpkin:
        - determine 15
        on player breaks melon:
        - determine 15
        on player places melon:
        - determine cancelled
        on player places pumpkin:
        - determine cancelled
