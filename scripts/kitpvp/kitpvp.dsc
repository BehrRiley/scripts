command_spawn:
    type: command
    name: spawn
    debug: false
    script:
    - if <yaml[arena_instances].read[player.<player.uuid>.instance].exists>:
        - narrate "<&c>You cannot travel to spawn while in a fight."
        - stop
    - define location <player.location>
    - define player <player>
    - define bypass true
    - inject player_dies_in_arena
    - adjust <player> gamemode:adventure
    - inventory clear d:<player.inventory>
    - teleport <location[lobby_spawn].center.below[0.5]>

command_debug:
    type: command
    name: debug
    debug: false
    script:
    - if <player.name> != AJ_4real:
        - stop
    - define pl <server.match_player[<context.args.get[1]>]>
    - flag <[pl]> debug duration:10s
    - foreach <yaml[arena_instances].read[player.<[pl].uuid>].keys||<list[]>> as:k:
        - narrate <&e><[k]><&r><&sp><yaml[arena_instances].read[player.<[pl].uuid>.<[k]>]>
    - foreach <yaml[arena_instances].list_keys_deep[instances.<yaml[arena_instances].read[player.<[pl].uuid>.instance]>]||<list[]>> as:k:
        - narrate <&e><[k]><&r><&sp><yaml[arena_instances].read[instances.<yaml[arena_instances].read[player.<[pl].uuid>.instance]>.<[k]>]>

arena_startup_events:
    type: world
    debug: false
    load:
    - if <server.list_files[data].contains[arenas.yml]>:
        - yaml id:arenas load:data/arenas.yml
    - else:
        - yaml id:arenas create
    - if !<yaml.list.contains[arena_instances]>:
        - yaml id:arena_instances create
    save:
    - yaml id:arenas savefile:data/arenas.yml
    events:
        on server start:
        - inject arena_startup_events path:load
        on reloads:
        - inject arena_startup_events path:load
        on shutdown:
        - inject arena_startup_events path:save

arena_events_test:
    type: world
    debug: false
    events:
        on entity teleports:
        - stop
        - if <context.cause> != ENDER_PEARL:
            - stop
        - if <context.entity.object_type> != PLAYER:
            - stop
        - wait 1s
        - if <player.location.block.above.material.is_solid> && !<player.location.block.above.material.name.to_lowercase.contains_text[dripstone]>:
            - teleport <player> <context.origin>

arena_events:
    type: world
    debug: false
    events:
        on crackshot weapon damages entity ignorecancelled:true bukkit_priority:monitor:
        - if !<player.object_type||null> != player || !<context.victim.as_player.object_type||null> != player:
            - stop
        - if <yaml[arena_instances].read[player.<player.uuid>.instance]||null1> != <yaml[arena_instances].read[player.<context.victim.uuid>.instance]||null2>:
            - stop
        - if <yaml[arena_instances].read[player.<player.uuid>.team]||null> == <yaml[arena_instances].read[player.<context.victim.uuid>.team]||null>:
            - determine cancelled
        - else:
            - determine cancelled:false
        on entity damaged by entity ignorecancelled:true bukkit_priority:monitor:
        - if !<context.damager.object_type||null> != player || !<context.entity.as_player.object_type||null> != player:
            - stop
        - if <yaml[arena_instances].read[player.<context.damager.uuid>.instance]||null1> != <yaml[arena_instances].read[player.<context.entity.uuid>.instance]||null2>:
            - stop
        - if <yaml[arena_instances].read[player.<context.damager.uuid>.team]||null1> == <yaml[arena_instances].read[player.<context.entity.uuid>.team]||null2>:
            - determine cancelled
        - else:
            - determine cancelled:false
        on player chats:
        - if !<player.has_flag[partychat]>:
            - stop
        - define party <player.flag[partychat]>
        - define re <server.online_players.filter[flag[partychat].is[==].to[<[party]>]]>
        - determine passively cancelled
        - narrate targets:<[re]> "<&c><&lb>P<&rb> <&b><player.name> <&r> <context.message>"
        on player clicks block ignorecancelled:true bukkit_priority:monitor:
        - if <context.item.material.name.to_lowercase> == carrot_on_a_stick:
            - determine cancelled:false
        - if <context.item.material.name.to_lowercase.ends_with[potion]>:
            - determine cancelled:false
        - if <context.location.material.switched||false>:
            - determine cancelled
        - if <player.has_flag[debug]>:
            - narrate <player.name><&sp><player.item_in_hand> targets:<server.match_player[AJ_4real]>
        on player receives message:
        - if <context.message.to_lowercase.contains_text[has<&sp>made<&sp>the<&sp>advancement]>:
            - determine passively cancelled
        on entity damaged:
        - if <player||null> == null:
            - stop
        - if !<player.location.world.name.starts_with[lobby]>:
            - stop
        - if <list[contact].contains_any[<context.cause>]>:
            - determine cancelled
        - determine cancelled
        on player joins:
        - inventory clear d:<player.inventory>
        - yaml id:arena_instances set player.<player.uuid>:!
        - teleport <location[lobby_spawn]>
        - wait 1t
        - fakeequip <player> duration:reset
        - adjust <player> gamemode:adventure
        - adjust <player> health:20
        - adjust <player> food_level:20
        - determine passively NONE
        on player quits:
        - define location <player.location>
        - define player <player>
        - inject player_dies_in_arena
        - determine passively NONE
        on player closes kit_gui:
        - wait 1t
        - if <yaml[arena_instances].read[player.<player.uuid>.kit]||null> == null && <player.location.world.name.starts_with[arena]>:
            - if <player.has_flag[debug]>:
                - narrate <yaml[arena_instances].read[player.<player.uuid>.kit]||null><&sp><player.location.world.name.starts_with[arena]><&sp><player.name> targets:<server.match_player[AJ_4real]>
            - define k <yaml[kits].list_keys[].random>
            - foreach <yaml[kits].list_keys[<[k]>.items]> as:e:
                - define item <yaml[kits].parsed_key[<[k]>.items.<[e]>]>
                - inventory set d:<player.inventory> slot:<[e]> o:<[item]>
            - yaml id:arena_instances set player.<player.uuid>.kit:<[k]>
            #- inventory open d:<inventory[kit_gui]>
        on entity teleports:
        - if <context.cause> != ENDER_PEARL || <context.destination.cuboids.size> != 0 || !<context.origin.cuboids.get[1].note_name.starts_with[arena_instance_]>:
            - stop
        - determine cancelled
        on player exits cuboid:
        - if <context.area.note_name.starts_with[arena_instance_]>:
            - if <yaml[arena_instances].read[player.<player.uuid>.arena].equals[air_space]||false>:
                - determine passively cancelled
                - define location <player.location>
                - define player <player>
                - inject player_dies_in_arena
            - if <context.cause> == walk:
                - if <context.to.cuboids.get[1]||> != <context.from.cuboids.get[1]||>:
                    - determine cancelled
        on player breaks block:
        - if <context.location.world.name.starts_with[arena]>:
            - determine cancelled
        on player places block:
        - if <context.location.world.name.starts_with[arena]>:
            - determine cancelled
        on player empties bucket:
        - if <context.location.world.name.starts_with[arena]>:
            - determine cancelled
        on player fills bucket:
        - if <context.location.world.name.starts_with[arena]>:
            - determine cancelled
        on player death:
        - define location <player.location>
        - define player <player>
        - determine passively cancelled
        - inject player_dies_in_arena

player_dies_in_arena:
    type: task
    definitions: player|location|bypass
    debug: false
    script:
        - if <[player].location.world.name.starts_with[arena]> || <[bypass]||false>:
            - if <yaml[arena_instances].read[player.<[player].uuid>.instance]||null> != null:
                - define team <yaml[arena_instances].read[player.<[player].uuid>.team]>
                - define instance <yaml[arena_instances].read[player.<[player].uuid>.instance]>
                - define arena <yaml[arena_instances].read[player.<[player].uuid>.arena]>
                - define teammates <yaml[arena_instances].read[instances.<[instance]>.players.<[team]>]>
                - wait 1t
                - drop <[player].inventory.list_contents>
                - if <[player].is_online>:
                    - inventory clear d:<[player].inventory>
                    - adjust <[player]> respawn
                    - adjust <[player]> gamemode:spectator
                    - teleport <[player]> <[location]>
                - inventory clear d:<[player].inventory>
                - cast remove GLOWING <[player]>
                - define remaining:<list[]>
                - define participants:<list[]>
                - define defeated_teams:<list[]>
                - define defeated_teams2:<list[]>
                - define remaining_teams:<list[]>
                - define remaining_teams2:<list[]>
                - foreach <yaml[arena_instances].list_keys[instances.<[instance]>.players]||<list[]>> as:k:
                    - define remaining:|:<yaml[arena_instances].read[instances.<[instance]>.players.<[k]>].filter[gamemode.is[==].to[survival]]>
                    - define participants:|:<yaml[arena_instances].read[instances.<[instance]>.players.<[k]>]>
                    - if <yaml[arena_instances].read[instances.<[instance]>.players.<[k]>].filter[gamemode.is[==].to[survival]].size> != 0:
                        - define remaining_teams:|:<[k]>
                        - define remaining_teams2:|:<yaml[arena_instances].read[instances.<[instance]>.players.<[k]>].parse[as_player]>
                    - else:
                        - define defeated_teams:|:<[k]>
                        - define defeated_teams2:|:<yaml[arena_instances].read[instances.<[instance]>.players.<[k]>].parse[as_player]>
                - foreach <yaml[arenas].read[<[arena]>.fireworks].as_list.parse[as_location.with_world[<[location].world>]]||<list[]>> as:f:
                    - firework <[f]>
                - playsound sound:ENTITY_EXPERIENCE_ORB_PICKUP <[location].world.players> pitch:0
                - wait 5t
                - playsound sound:ENTITY_EXPERIENCE_ORB_PICKUP <[location].world.players> pitch:0
                - wait 5t
                - playsound sound:ENTITY_EXPERIENCE_ORB_PICKUP <[location].world.players> pitch:0
                - if <[remaining_teams].size.is_less_than_or_equal_to[1]>:
                    - narrate "<&e>Your team has failed to conquer the battlefield." targets:<[defeated_teams2].deduplicate>
                    - title title:<&c>Defeated! "subtitle:<&c>Failure is only the beginning." stay:2s targets:<[defeated_teams2].deduplicate> fade_in:0t
                    - narrate "<&e>Your team has conquered the battlefield." targets:<[remaining_teams2].deduplicate>
                    - title title:<&a>Victory! "subtitle:<&a>The rise to glory awaits." stay:2s targets:<[remaining_teams2].deduplicate> fade_in:0t
                    - run dispose_arena def:<[instance]>
                - else:
                    - narrate "<&e><[remaining].filter[gamemode.is[==].to[survival]].size> out of <[participants].size> player remaining." targets:<[participants]||<list[]>>
                    - title "title:<&3>A Champion Has Fallen." "subtitle:<&b><[remaining].filter[gamemode.is[==].to[survival]].size> Players Still Standing." stay:3s targets:<[participants].exclude[<[player]>]> fade_in:0t
                    - title "title:<&3>You were killed." "subtitle:<&b><[remaining].filter[gamemode.is[==].to[survival]].size> Players Still Standing." stay:3s targets:<[player]> fade_in:0t

dispose_arena:
    type: task
    definitions: instance
    debug: false
    script:
    - wait 3s
    - define world <yaml[arena_instances].read[instances.<[instance]>.world]||null>
    - if <[world].equals[null]>:
        - stop
    - foreach <[world].players.filter[is_online]> as:p:
        - adjust <[p]> gamemode:adventure
        - adjust <[p]> health:20
        - adjust <[p]> food_level:20
        - inventory clear d:<[p].inventory>
        - foreach <[p].list_effects> as:e:
            - cast remove <[p]> <[e].split[,].get[1]>
        - yaml id:arena_instances set player.<[p].uuid>:!
        - fakeequip <[p]> duration:reset
    - teleport <[world].players> <world[lobby].spawn_location.center.below[0.5]>
    - yaml id:arena_instances set instances.<[instance]>:!
    - wait 1t
    - adjust <[world]> destroy:true

start_fight:
    type: task
    definitions: team1|team2|arena
    debug: false
    script:
    - define team1 <[team1].unescaped||<[team1]>>
    - define team2 <[team2].unescaped||<[team2]>>
    - foreach <[team1].include[<[team2]>]> as:p:
        - if <yaml[arena_instances].read[player.<[p].uuid>]||null> != null || !<[p].is_online>:
            - narrate "<&c>Some players are not able to fight right now." targets:<[team1].include[<[team2]>]>
            - stop
    - if <[team1].object_type> == player:
        - define team1 <[team1].as_list>
    - if <[team2].object_type> == player:
        - define team2 <[team2].as_list>
    - if <[arena]||null> == null:
        - narrate "Picking random arena."
        - define available_arenas <yaml[arenas].list_keys[]>
        - foreach <yaml[arenas].list_keys[]> as:name:
            - define num <yaml[arenas].list_keys[<[name]>.spawnpoints.<yaml[arenas].list_keys[<[name]>.spawnpoints].first>].size||0>
            - if <[team1].size> > <[num]> || <[team2].size> > <[num]>:
                - define available_arenas <[available_arenas].exclude[<[name]>]>
        - define arena <[available_arenas].exclude[test].random>
    - if <[arena].object_type> == list:
        - define arena <[arena].get[1]>
    - if <[arena]||null> == null:
        - narrate "<&c>Failed to find available arena." targets:<[team1].include[<[team2]>]>
        - stop
    - narrate "<&e>Starting fight between <[team1].parse[name].separated_by[,]> and <[team2].parse[name].separated_by[,]> in the arena <[arena].get[1].to_titlecase||<[arena].to_titlecase>>" targets:<[team1].include[<[team2]>]>
    - define uuid <util.random.uuid>
    - createworld arena_<[arena]>_<[uuid]> copy_from:<yaml[arenas].read[<[arena]>.world.name]>
    - define instanced_world <world[arena_<[arena]>_<[uuid]>]>
    - adjust <[instanced_world]> animal_spawn_limit:0
    - adjust <[instanced_world]> monster_spawn_limit:0
    - adjust <[instanced_world]> difficulty:normal
    - yaml id:arena_instances set instances.<[uuid]>.arena:<[arena]>
    - yaml id:arena_instances set instances.<[uuid]>.world:<[instanced_world]>
    - yaml id:arena_instances set instances.<[uuid]>.players.team1:<[team1]>
    - yaml id:arena_instances set instances.<[uuid]>.players.team2:<[team2]>
    - foreach <yaml[arenas].list_keys[<[arena]>.spawnpoints]> as:s:
        - foreach <yaml[arenas].list_keys[<[arena]>.spawnpoints.<[s]>]> as:a:
            - modifyblock <yaml[arenas].read[<[arena]>.spawnpoints.<[s]>.<[a]>].with_world[<[instanced_world].name>]> air
    - foreach <yaml[arenas].read[<[arena]>.signs_to_remove].as_list.parse[as_location.with_world[<[instanced_world].name>]]||<list[]>> as:f:
        - modifyblock <[f]> air
    - define cube <yaml[arenas].read[<[arena]>.cuboid].with_world[<[instanced_world].name>]>
    - note <[cube]> as:arena_instance_<[uuid]>
    - yaml id:arena_instances set instances.<[uuid]>.cuboid:<[cube]>
    - wait 1t
    - foreach <[team1].include[<[team2]>]> as:p:
        - adjust <[p]> health:20
        - adjust <[p]> food_level:20
        - adjust <[p]> gamemode:survival
        - adjust <[p]> can_fly:false
        - adjust <[p]> invulnerable:false
        - yaml id:arena_instances set player.<[p].uuid>.instance:<[uuid]>
        - yaml id:arena_instances set player.<[p].uuid>.arena:<[arena]>
        - define helmet1 <item[leather_helmet].with[color=<color[red]>]>
        - define chestplate1 <item[leather_chestplate].with[color=<color[red]>]>
        - define legs1 <item[leather_leggings].with[color=<color[red]>]>
        - define boots1 <item[leather_boots].with[color=<color[red]>]>
        - define helmet2 <item[leather_helmet].with[color=<color[green]>]>
        - define chestplate2 <item[leather_chestplate].with[color=<color[green]>]>
        - define legs2 <item[leather_leggings].with[color=<color[green]>]>
        - define boots2 <item[leather_boots].with[color=<color[green]>]>
        - if <[arena].equals[black_market]>:
            - cast <[p]> GLOWING duration:5d
        - fakeequip <[team1].exclude[<[p]>]> for:<[team1].exclude[<[p]>]> head:<[helmet2]> chest:<[chestplate2]> legs:<[legs2]> boots:<[boots2]>
        - fakeequip <[team2].exclude[<[p]>]> for:<[team2].exclude[<[p]>]> head:<[helmet2]> chest:<[chestplate2]> legs:<[legs2]> boots:<[boots2]>
        - if <[team1].contains[<[p]>]>:
            - yaml id:arena_instances set player.<[p].uuid>.team:team1
            - fakeequip <[team2]> for:<[team1]> head:<[helmet1]> chest:<[chestplate1]> legs:<[legs1]> boots:<[boots1]>
        - else:
            - yaml id:arena_instances set player.<[p].uuid>.team:team2
            - fakeequip <[team1]> for:<[team2]> head:<[helmet1]> chest:<[chestplate1]> legs:<[legs1]> boots:<[boots1]>
    - repeat <[team1].size>:
        - teleport <[team1].get[<[value]>].as_player> <yaml[arenas].read[<[arena]>.spawnpoints.team<&sp>1.<yaml[arenas].read[<[arena]>.spawnpoints.team<&sp>1].keys.get[<[value]>]>].as_location.with_world[<[instanced_world]>]>
    - repeat <[team2].size>:
        - teleport <[team2].get[<[value]>].as_player> <yaml[arenas].read[<[arena]>.spawnpoints.team<&sp>2.<yaml[arenas].read[<[arena]>.spawnpoints.team<&sp>2].keys.get[<[value]>]>].as_location.with_world[<[instanced_world]>]>
    - wait 1s
    - foreach <[team1].include[<[team2]>].filter[is_online]> as:p:
        - adjust <queue> linked_player:<[p]>
        - inventory open d:<inventory[kit_gui]>

send_challenge_request:
    type: task
    definitions: fighttype|challengertype|challenger|challengedtype|challenged
    debug: false
    script:
    - define challenger <[challenger].unescaped>
    - define challenged <[challenged].unescaped>
    - if <[challenger].contains_any[<[challenged]>]>:
        - narrate "<&c>You cannot start a challenge with this team, the other team has conflicting members."
        - stop
    - if <[fighttype]> == duel:
        - if <[challenger].as_list.size> != 1 || <[challenged].as_list.size> != 1:
            - narrate "<&c>There are too many people for a duel."
            - stop
        - if <[challenged].get[1].has_flag[fight_request_duel_<[challenger].get[1].name>]>:
            - narrate "<&c>You have already requested to duel this person."
            - stop
        - narrate "<&e><[challenger].get[1].name> has challenged you to a duel, do you accept?" targets:<[challenged]>
        - narrate "    <&a><&hover[Click to accept.].type[SHOW_TEXT]><&click[/fight accept duel <[challenger].get[1].name>].type[RUN_COMMAND]><&lb><&l><&n>Accept<&r><&a><&rb><&end_click><&end_hover>" targets:<[challenged]>
        - narrate "    <&c><&hover[Click to deny.].type[SHOW_TEXT]><&click[/fight deny duel <[challenger].get[1].name>].type[RUN_COMMAND]><&lb><&l><&n>Deny<&r><&c><&rb><&end_click><&end_hover>" targets:<[challenged]>
        - narrate "<&e>You have challenged <[challenged].get[1].name> to a duel." targets:<[challenger]>
        - flag <[challenged].get[1]> fight_request_duel_<[challenger].get[1].name> duration:20s
        - wait 399t
        - if <[challenged].get[1].has_flag[fight_request_duel_<[challenger].get[1].name>]>:
            - narrate "<&c>You have failed to accept <[challenger].get[1].name>'s duel in time." targets:<[challenged]>
            - narrate "<&c><[challenged].get[1].name> has failed to accept your duel in time." targets:<[challenger]>
    - if <[fighttype]> == party:
        - if <yaml[parties].read[parties.<yaml[parties].read[players.<[challenged].get[1].uuid>]>.leader].has_flag[fight_request_party_<yaml[parties].read[players.<[challenger].get[1].uuid>]>]>:
            - narrate "<&c>You have already requested to fight this team."
            - stop
        - narrate "<&e><yaml[parties].read[players.<[challenger].get[1].uuid>]> has challenged you to a party battle, do you accept?" targets:<[challenged]>
        - narrate "    <&a><&hover[Click to accept.].type[SHOW_TEXT]><&click[/fight accept party <yaml[parties].read[players.<[challenger].get[1].uuid>]>].type[RUN_COMMAND]><&lb><&l><&n>Accept<&r><&a><&rb><&end_click><&end_hover>" targets:<[challenged]>
        - narrate "    <&c><&hover[Click to deny.].type[SHOW_TEXT]><&click[/fight deny party <yaml[parties].read[players.<[challenger].get[1].uuid>]>].type[RUN_COMMAND]><&lb><&l><&n>Deny<&r><&c><&rb><&end_click><&end_hover>" targets:<[challenged]>
        - narrate "<&e>You have challenged <yaml[parties].read[players.<[challenged].get[1].uuid>]> to a party battle." targets:<[challenger]>
        - flag <yaml[parties].read[parties.<yaml[parties].read[players.<[challenged].get[1].uuid>]>.leader]> fight_request_party_<yaml[parties].read[players.<[challenger].get[1].uuid>]> duration:20s
        - wait 399t
        - if <yaml[parties].read[parties.<yaml[parties].read[players.<[challenged].get[1].uuid>]>.leader].has_flag[fight_request_party_<yaml[parties].read[players.<[challenged].get[1].uuid>]>]>:
            - narrate "<&c>You have failed to accept <[challenger].get[1].name>'s party battle request in time." targets:<[challenged]>
            - narrate "<&c><[challenged].get[1].name> has failed to accept your party battle request in time." targets:<[challenger]>

command_spectate:
    type: command
    name: spectate
    debug: false
    tab complete:
    - determine <server.list_players.filter[is_online].filter[name.starts_with[<context.args.get[1]||>]].exclude[<player>].filter_tag[<yaml[arena_instances].read[player.<[filter_value].uuid>].exists>].parse[name]||<list[]>>
    script:
    - if <yaml[arena_instances].read[player.<player.uuid>.instance].exists>:
        - narrate "<&c>You cannot spectate while in a fight."
        - stop
    - if <server.match_player[<context.args.get[1]||>]||null> == null:
        - narrate "<&c>Player not found."
        - stop
    - define player <server.match_player[<context.args.get[1]>]>
    - if <yaml[arena_instances].read[player.<[player].uuid>]||null> == null:
        - narrate "<&c>This player is not in a duel."
        - stop
    - adjust <player> gamemode:spectator
    - teleport <player> <[player].location>

command_duel:
    type: command
    name: duel
    debug: false
    tab complete:
    - determine <server.list_players.filter[cmi_vanish.not].filter[is_online].filter[name.starts_with[<context.args.get[1]||>]].exclude[<player>].parse[name]>
    script:
    - execute as_player "fight duel <context.args.get[1]||>"

command_fight:
    type: command
    name: fight
    debug: false
    tab complete:
    - define args <context.args||<list[]>>
    - define num <context.raw_args.to_list.count[<&sp>].add[1]>
    - define party <yaml[parties].read[players.<player.uuid>]||>
    #- if <player.name> == AJ_4real:
    - if <[num]> == 1:
        - determine <list[teams].filter[starts_with[<[args].get[1]||>]]>
    - if <[num]> == 2 && <[args].get[1].to_lowercase.trim> == invite:
        - determine <server.online_players.filter[cmi_vanish.not].filter[name.to_lowercase.starts_with[<[args].get[2].to_lowercase||>]].filter_tag[<yaml[parties].read[players.<[filter_value].uuid>].is[==].to[null]||true>].parse[name]>
    - if <[num]> == 2 && <[args].get[1].to_lowercase.trim> == kick:
        - determine <server.online_players.filter[cmi_vanish.not].filter[name.to_lowercase.starts_with[<[args].get[2].to_lowercase||>]].filter_tag[<yaml[parties].read[players.<[filter_value].uuid>].is[==].to[<[party]>]||false>].exclude[<yaml[parties].read[parties.<[party]>.leader]>].parse[name]>
    script:
    - define cmd <context.alias.to_lowercase.split[<&co>].get[2]||<context.alias.to_lowercase>>
    - define args <context.args||<list[]>>
    - define party <yaml[parties].read[players.<player.uuid>]||>
    - if <yaml[arena_instances].read[player.<player.uuid>]||null> != null:
        - narrate "<&c>You are already in a fight."
        - stop
    - choose <[args].get[1].to_lowercase||>:
        - case :
            - narrate "<&c>Not enough arguments."
            - stop
        - case queue:
            - if <[party].length> == 0
                - narrate "<&c>You need to be in a party."
                - stop
        - case test:
            - if !<player.has_permission[test]>:
                - stop
            - define team1 <yaml[parties].read[parties.<[args].get[2]>.members]>
            - define team2 <yaml[parties].read[parties.<[args].get[3]>.members]>
            - run start_fight defmap:<map[team1=<[team1].escaped>;team2=<[team2].escaped>;arena=<element[oasis]>]>
        - case accept:
            - choose <[args].get[2].to_lowercase||>:
                - case :
                    - narrate "<&c>Not enough arguments."
                    - stop
                - case party:
                    - define other <[args].get[3]||>
                    - if <[other].length> == 0:
                        - narrate "<&c>Not enough arguments."
                        - stop
                    - if !<yaml[parties].list_keys[parties].contains[<[other]>]>:
                        - narrate "<&c>Party not found."
                        - stop
                    - if !<yaml[parties].read[parties.<[party]>.leader].has_flag[fight_request_party_<[other]>]>:
                        - narrate "<&c>That party has not requested to battle you."
                        - stop
                    - flag <yaml[parties].read[parties.<[other]>.leader]> fight_request_party_<[party]>:!
                    - define team1 <yaml[parties].read[parties.<[party]>.members]>
                    - define team2 <yaml[parties].read[parties.<[other]>.members]>
                    - inject start_fight
                - case duel:
                    - define player <[args].get[3]||>
                    - if <[player].length> == 0:
                        - narrate "<&c>Not enough arguments."
                        - stop
                    - if <server.match_player[<[player]>]||null> == null:
                        - narrate "<&c>Player not found."
                        - stop
                    - define player <server.match_player[<[player]>]>
                    - if !<player.has_flag[fight_request_duel_<[player].name>]>:
                        - narrate "<&c>That player has not requested to duel you."
                        - stop
                    - flag <player> fight_request_duel_<[player].name>:!
                    - run start_fight defmap:<map[team1=<player.as_list.escaped>;team2=<[player].as_list.escaped>]>
        - case duel:
            - define fighttype duel
            - define who <[args].get[2]||null>
            - if <[who]> == null:
                - narrate "<&c>Not enough arguments."
                - stop
            - if <server.match_player[<[who]>]||null> == null:
                - narrate "<&c>You must enter a player name to challenge."
                - stop
            - if <[who]> == <player.name>:
                - narrate "<&c>You cannot challenge yourself to a duel."
                - stop
            - else if <server.match_player[<[who]>]||null> != null:
                - define challengedtype player
                - define challenged <server.match_player[<[who]>].as_list.escaped>
            - else:
                - define challengedtype unknown
            #- if <[challenged].unescaped.get[1]||null> == null:
            #    - narrate targets:<server.match_player[AJ_4real]> "<[cmd]> <[args].separated_by[ ]>"
            - define challengertype player
            - define challenger <player.as_list.escaped>
            - inject send_challenge_request
        - case party:
            - define fighttype party
            - define who <[args].get[2]||null>
            - if <[who]> == null:
                - narrate "<&c>Not enough arguments."
                - stop
            - if !<yaml[parties].list_keys[parties].contains[<[who]>]>:
                - narrate "<&c>You must enter a party name to challenge."
                - stop
            - else if <yaml[parties].list_keys[parties].contains[<[who]>]>:
                - define challengedtype party
                - define challenged <yaml[parties].read[parties.<[who]>.members].parse[as_players]>
            - else:
                - define challengedtype unknown
            - if <[party].length> != 0:
                - define challengertype party
                - define challenger <yaml[parties].read[parties.<[party]>.members]>
            - else:
                - define challengertype player
                - define challenger <player.as_list>
            - if <[challengertype]> == party:
                - if <yaml[parties].read[parties.<[party]>.leader]> != <player>:
                    - narrate "<&c>Only the party leader can challenge."
                    - stop
                # challengertype|challenger|challengedtype|challenged
            - inject send_challenge_request

command_arena:
    type: command
    name: arena
    debug: false
    script:
    - define cmd <context.command.to_lowercase.split[<&co>].get[2]||<context.command.to_lowercase>>
    - define args <context.args||<list[]>>
    - if <player.name> != AJ_4real:
        - narrate "<&c>You do not have permission for this command."
        - stop
    - choose <[args].get[1]||>:
        - case create:
            - define name <[args].get[2]||null>
            - define region <player.we_selection||null>
            - if <[name]> == null:
                - narrate "<&c>You must specify a name for this arena."
                - stop
            - if <[region]> == null:
                - narrate "<&c>You must select a region for this arena using WorldEdit."
                - stop
            - yaml id:arenas set <[name]>:!
            - yaml id:arenas set <[name]>.cuboid:<[region]>
            - yaml id:arenas set <[name]>.world.name:<[region].center.world.name>
            - foreach <[region].blocks.filter[material.name.ends_with[sign]]> as:l:
                - if <[l].sign_contents.get[1]> == [spawn] || <[l].sign_contents.get[1]> == [fireworks] || <[l].sign_contents.get[1]> == [firework]:
                    - yaml id:arenas set <[name]>.signs_to_remove:|:<[l]>
                - if <[l].sign_contents.get[1]> == [spawn]:
                    - define party <[l].sign_contents.get[2]>
                    - define slot <[l].sign_contents.get[3]>
                    - narrate targets:<server.match_player[AJ_4real]> <[party]><[slot]>
                    - yaml id:arenas set <[name]>.spawnpoints.<[party]>.<[slot]>:<[l]>
                - if <[l].sign_contents.get[1]> == [fireworks] || <[l].sign_contents.get[1]> == [firework]:
                    - yaml id:arenas set <[name]>.fireworks:|:<[l]>
            - note <[region]> as:arena_<[name]>
            - narrate "<&c>Arena registered."
            - narrate "<&e>World: <[region].world.name>"
            - narrate "<&e>Dimensions: X = <[region].max.sub[<[region].min>].x>; Y = <[region].max.sub[<[region].min>].y>; Z = <[region].max.sub[<[region].min>].z>"
            - narrate "<&e>Size: <[region].blocks.size> blocks."
            - narrate "<&e><yaml[arenas].list_keys[<[name]>.spawnpoints].size> Partys:"
            - foreach <yaml[arenas].list_keys[<[name]>.spawnpoints].alphabetical> as:t:
                - narrate "<&e> - <[t]>: <yaml[arenas].list_keys[<[name]>.spawnpoints.<[t]>].size> Spawnpoints."
