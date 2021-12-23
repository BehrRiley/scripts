player_meta_events:
    type: world
    debug: false
    events:
        on player kills player bukkit_priority:monitor:
        - define killed <context.entity>
        - define killer <context.damager>
        - flag <[killed]> stats.pvp.deaths:+:1
        - flag <[killer]> stats.pvp.kills:+:1
        - townymeta <[killed]> key:stats.pvp.deaths "label:PVP Deaths" value:<[killed].flag[stats.pvp.deaths]>
        - townymeta <[killer]> key:stats.pvp.kills "label:PVP Kills" value:<[killer].flag[stats.pvp.kills]>
