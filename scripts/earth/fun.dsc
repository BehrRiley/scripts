
mage_spell_summon_vex:
    type: task
    path: summon
    name: vex
    depends: []
    script:
    - if <player.location.find.players.within[20].exclude[<player>].size> != 0:
        - define target <player.location.find.players.within[20].exclude[<player>].random>
    - else:
        - define target <player.target||<player.location.find_entities.within[20].exclude[<player>].filter[is_living].filter[is_spawned].random||null>>
    - if <[target]> == null:
        - stop
    - if !<[target].is_living>:
        - stop
    - if !<[target].is_spawned>:
        - stop
    - define points <proc[define_sphere1].context[<player.location>|3|1].filter[block.material.is_solid.not].random[6]>
    - foreach <[points]> as:point:
        - spawn vex <[point]> save:vex
        - define vex <entry[vex].spawned_entity>
        - define entities:|:<[vex]>
        - attack <[vex]> target:<[target]>
        - playeffect at:<proc[define_sphere1].context[<[point].add[<location[0,0.5,0]>]>|0.5|0.2]> WITCH_MAGIC offset:0
        - wait 1t
    - waituntil <[target].health||0> == 0 || <[entities].filter[time_lived.is_less_than[30s]].size||0> == 0
    - remove <[entities].filter[is_spawned]>