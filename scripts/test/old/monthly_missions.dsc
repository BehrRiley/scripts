monthly_missions_startup:
    type: world
    debug: false
    load:
    - if !<server.list_files[data].contains[monthly_missions.yml]>:
        - yaml create id:monthly_missions
    - else:
        - yaml id:monthly_missions load:data/monthly_missions.yml
    - yaml id:monthly_missions savefile:data/monthly_missions.yml
    save:
    - yaml id:monthly_missions savefile:data/monthly_missions.yml
    events:
        on reload scripts:
        - inject monthly_missions_startup path:load
        on server start:
        - inject monthly_missions_startup path:load
        on shutdown:
        - inject monthly_missions_startup path:save
        on player breaks block:
        - if <yaml[monthly_missions].read[current.item]||null> == <context.material.name>:
            - run contribute_monthly_mission defmap:<map[player=<player>;type=break_block]>

monthly_mission_event_inventory:
    type: inventory
    inventory: chest
    size: 45
    gui: true
    title: <&l><&b>Monthly Mission
    procedural items:
    - define mission <item[paper]>
    - define txt <proc[colorize].context[<yaml[monthly_missions].read[strings.mission.<yaml[monthly_missions].read[current.type]>.<yaml[monthly_missions].read[current.item]>].replace[<&pc>current<&pc>].with[<yaml[monthly_missions].read[overall.amount].format_number>].replace[<&pc>requirement<&pc>].with[<yaml[monthly_missions].read[current.requirement].format_number>]>]>
    - define mission "<[mission].with[lore=<list[<[txt].to_titlecase>]>;display=<&e><yaml[monthly_missions].read[current.requirement].format_number> <yaml[monthly_missions].read[current.item].to_titlecase>]>"
    - define items:|:<[mission]>
    - define lb <yaml[monthly_missions].list_keys[player].sort[monthly_mission_test]||<list[]>>
    - foreach <[lb].get[1].to[7]||<list[]>>:
        - define p <[value].as_player>
        - define head <[p].skull_item||null>
        - if <[head].equals[null].not>:
            - define head <[head].with[display=<&e><[p].name>]>
            - define lore "<list[<&e>Contribution: <yaml[monthly_missions].read[player.<[p].uuid>.amount]>|<&e>Town: <[p].town.name||None>|<&e>Nation: <[p].nation.name||None>]>"
            - define head <[head].with[lore=<[lore]>]>
            - define items:|:<[head]>
    - determine <[items]>
    definitions:
        ui: <item[light_gray_stained_glass_pane].with[display=<&sp>]>
    slots:
        - [ui] [ui] [ui] [ui] [ui] [ui] [ui] [ui] [ui]
        - [ui] [ui] [ui] [ui] [] [ui] [ui] [ui] [ui]
        - [ui] [] [] [] [] [] [] [] [ui]
        - [ui] [ui] [ui] [ui] [] [ui] [ui] [ui] [ui]
        - [ui] [ui] [ui] [ui] [ui] [ui] [ui] [ui] [ui]

monthly_mission_test:
    type: procedure
    definitions: value1|value2
    debug: false
    script:
    - define value1 <yaml[monthly_missions].read[player.<[value1]>.amount]>
    - define value2 <yaml[monthly_missions].read[player.<[value2]>.amount]>
    - if <[value1]> < <[value2]>:
        - determine 1
    - if <[value1]> > <[value2]>:
        - determine -1
    - if <[value1]> == <[value2]>:
        - determine 0

contribute_monthly_mission:
    type: task
    debug: false
    definitions: player|type
    script:
    - if <[player].uuid||null> == null:
        - if <player||null> == null:
            - stop
        - else:
            - define player <player>
    - define type2 <yaml[monthly_missions].read[current.type]>
    - if <[type]> != <[type2]>:
        - if <[type]> == turn_in:
            - narrate "<&c>This is not a turn in mission." targets:<[player]>
        - stop
    - define item <yaml[monthly_missions].read[current.item]>
    - define amount <[player].inventory.list_contents.filter[script||true].filter[material.name.equals[<[item]>]].parse[quantity].sum||0>
    - if <[type]> == break_block:
        - define amount 1
    - if <[amount]> == 0:
        - narrate "<&c>You have nothing to contribute." targets:<[player]>
        - stop
    - define requirement <yaml[monthly_missions].read[current.requirement]>
    - define remaining <[requirement].sub[<[amount]>]>
    - if <[remaining].is_less_than_or_equal_to[0]>:
        - if <[type]> == turn_in:
            - take from:<[player].inventory> item:<[item]> quantity:<[amount].sub[<[remaining]>]>
    - else:
        - yaml id:monthly_missions set player.<[player].uuid>.amount:+:<[amount]>
        - yaml id:monthly_missions set overall.amount:+:<[amount]>
        - if <[type]> == turn_in:
            - take from:<[player].inventory> item:<[item]> quantity:<[amount]>
            - narrate <proc[colorize].context[<yaml[monthly_missions].read[strings.mission.<[type]>.<[item]>].replace[<&pc>current<&pc>].with[<yaml[monthly_missions].read[player.<[player].uuid>.amount]>].replace[<&pc>requirement<&pc>].with[<[requirement]>]>]>

start_monthly_mission:
    type: task
    debug: false
    definitions: override
    script:
    - define type1 <yaml[monthly_missions].list_keys[monthly].random>
    - define type2 <yaml[monthly_missions].list_keys[monthly.<[type1]>].random>
    - define min <yaml[monthly_missions].read[monthly.<[type1]>.<[type2]>.min]>
    - define max <yaml[monthly_missions].read[monthly.<[type1]>.<[type2]>.max]>
    - define requirement <util.random.int[<[min]>].to[<[max]>]>
    - yaml id:monthly_missions set current.month:<util.time_now.month>
    - yaml id:monthly_missions set current.type:<[type1]>
    - yaml id:monthly_missions set current.item:<[type2]>
    - yaml id:monthly_missions set current.requirement:<[requirement]>
    - define message <yaml[monthly_missions].read[strings.messages.start].include[<yaml[monthly_missions].read[strings.mission.<[type1]>.<[type2]>].replace[<&pc>requirement<&pc>].with[<[requirement]>].replace[<&pc>current<&pc>].with[0]>].parse[replace[<&pc>overall_reward<&pc>].with[<server.economy.format[<yaml[monthly_missions].read[monthly.<[type1]>.<[type2]>.reward.money]>]>]].parse_tag[<proc[colorize].context[<[parse_value]>]>]>
    - announce <[message].separated_by[<&nl>]>
    - yaml id:monthly_missions set overall.amount:0
    - inject monthly_missions_startup path:save

command_monthlymissions:
    type: command
    name: monthlymissions
    aliases:
    - mm
    - mms
    tab complete:
    - determine <list[contribute|contrib]>
    script:
    - define cmd <context.alias.to_lowercase.split[<&co>].get[2]||<context.alias.to_lowercase>>
    - define args <context.args||<list[]>>
    - if <player.has_permission[monthlymissions.admin]>:
        - choose <[cmd].get[1].to_lowercase||>:
            - case admin:
                - choose <[cmd].get[2].to_lowercase||>:
                    - case start:
                        - if <yaml[monthly_missions].read[current.month]> == <util.time_now.month>:
                            - narrate "<&c>There is already a monthly mission."
                            - stop
                        - run start_monthly_mission
    - if <yaml[monthly_missions].read[current.type]||null> == null:
        - narrate "<&c>There is no active monthly mission."
        - stop
    - if <[args].get[1]||null> == null:
        #- narrate "current monthly mission: <yaml[monthly_missions].read[overall.amount].format_number> out of <yaml[monthly_missions].read[current.requirement].format_number> <yaml[monthly_missions].read[current.item]>"
        #- narrate "note to self; must make this message look better."
        - inventory open d:monthly_mission_event_inventory
        - stop
    - if <list[contribute|contrib|turnin].contains[<[args].get[1].to_lowercase||>]>:
        - run contribute_monthly_mission defmap:<map[player=<player>;type=turn_in]>
