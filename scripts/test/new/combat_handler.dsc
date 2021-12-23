fake_armor_toggle:
  type: command
  name: fake_armor_toggle
  debug: false
  usage: /fake_armor_toggle
  description: toggles relative colored armor for war
  script:
    - narrate "<&c>Sorry, this is currently disabled."
    - stop
    - if <player.has_flag[playersettings.relative_armor_color.enabled]>:
      - flag player playersettings.relative_armor_color.enabled:!
      - run fake_armor_task_off
      - narrate "<&e>You are no longer seeing armor colors relative to your relationship."
    - else:
      - flag player playersettings.relative_armor_color.enabled
      - run fake_armor_task_on
      - narrate "<&e>You are now seeing armor colors relative to your relationship."

fake_armor_update_self:
  type: task
  debug: false
  script:
  - if <player.nation.exists>:
    - define enemies <player.nation.enemies.parse[residents].combine.filter[is_online].filter[has_flag[playersettings.relative_armor_color.enabled]]>
    - define allies <player.nation.allies.parse[residents].combine.filter[is_online].filter[has_flag[playersettings.relative_armor_color.enabled]]>
    - foreach <player.equipment_map> key:slot as:value:
      - if <[value].material.name> != air:
        - if !<[enemies].is_empty>:
          - fakeequip <player> for:<[enemies]> <[slot]>:leather_<[slot]>[color=<color[red]>]
        - if !<[allies].is_empty>:
          - fakeequip <player> for:<[allies]> <[slot]>:leather_<[slot]>[color=<color[#00c8ff]>]

fake_armor_task_off:
  type: task
  debug: false
  script:
  - if <player.nation.exists>:
    - define enemies <player.nation.enemies.parse[residents].combine.filter[is_online].combine>
    - define allies <player.nation.allies.parse[residents].combine.filter[is_online].combine>
    - if !<[allies].include[<[enemies]>].is_empty>:
      - fakeequip <[allies].include[<[enemies]>]> for:<player> reset

fake_armor_task_on:
  type: task
  debug: false
  script:
  - if <player.nation.exists>:
    - define enemies <player.nation.enemies.parse[residents].combine.filter[is_online]>
    - define allies <player.nation.allies.parse[residents].combine.filter[is_online]>
    - if !<[enemies].is_empty>:
      - foreach <[enemies]> as:target:
        - foreach <[target].equipment_map> key:slot as:value:
          - if <[value].material.name> != air:
            - fakeequip <[target]> for:<player> <[slot]>:leather_<[slot]>[color=<color[red]>]
        - wait 1t
    - if !<[allies].is_empty>:
      - foreach <[allies]> as:target:
        - foreach <[target].equipment_map> key:slot as:value:
          - if <[value].material.name> != air:
            - fakeequip <[target]> for:<player> <[slot]>:leather_<[slot]>[color=<color[#00c8ff]>]
        - wait 1t
    - wait 1t
    - run fake_armor_update_self

fake_armor_events:
    type: world
    debug: false
    config:
        playersettings:
            relative_armor_color:
                enemy: red
                ally: <&ns>00c8ff
                enabled: true
    events:
      after player logs in flagged:playersettings.relative_armor_color.enabled server_flagged:bork:
        - run fake_armor_task_on
      on player equips|unequips armor server_flagged:bork:
        - run fake_armor_update_self


command_pvp_off:
    type: command
    name: pvpoff
    debug: false
    script:
    - flag <player> no_pvp_damage:!
    - flag <player> no_damage:!
    - narrate "You do not have PvP protection."

run_combat_check:
    type: task
    debug: false
    script:
        - if <[attacker].name.equals[AJ_4real]>:
            - narrate test target:<server.match_player[AJ_4real]>
        - if <[attacker]> == <[victim]>:
            - stop
        - if !<[attacker].is_player> || !<[victim].is_player>:
            - stop
        - if <[attacker].has_flag[no_damage]> || <[attacker].has_flag[no_pvp_damage]>:
            - determine cancelled
        - if <[attacker].mcmmo.party||null1> == <[victim].mcmmo.party||null2>:
            - determine cancelled
        - if <[attacker].inventory.list_contents.filter[material.name.equals[air].not].size.equals[0]> || <[victim].inventory.list_contents.filter[material.name.equals[air].not].size.equals[0]>:
            - determine cancelled
        - if <[attacker].location.is_siege_zone||true> && <[victim].location.is_siege_zone||true>:
            - determine passively cancelled:false
        - if <[attacker].location.town.pvp||true> && <[victim].location.town.pvp||true>:
            - determine passively cancelled:false
        - if <[attacker].location.chunk.pvp> && <[victim].location.chunk.pvp>:
            - determine passively cancelled:false
        - if <[victim].has_flag[combat]||false>:
            - determine passively cancelled:false
        - if !<context.cancelled>:
            - if !<[attacker].has_flag[combat]>:
                - narrate "<&b>You are now in combat!" targets:<list[<[attacker]>]>
            - if !<[victim].has_flag[combat]>:
                - narrate "<&b>You are now in combat!" targets:<list[<[victim]>]>
            - flag <[attacker]> combat duration:45s
            - flag <[victim]> combat duration:45s
            - if <[attacker].has_flag[combat]>:
                - if !<server.current_bossbars.contains[combat_time<[attacker].uuid>]>:
                    - bossbar combat_time<[attacker].uuid> players:<[attacker]> "title:<&c>You are now in combat." color:RED
            - if <[victim].has_flag[combat]>:
                - if !<server.current_bossbars.contains[combat_time<[victim].uuid>]>:
                    - bossbar combat_time<[victim].uuid> players:<[victim]> "title:<&c>You are now in combat." color:RED

combat_log_events:
    type: world
    debug: false
    config:
        defaults:
            combat_tag:
                blocked_commands:
                - t spawn
                - n spawn
                - res spawn
    events:
        on delta time secondly every:10:
        - foreach <server.online_players.filter[inventory.list_contents.size.equals[0]]> as:p:
            - if <[p].location.is_siege_zone>:
                - cast WITHER amplifier:3 duration:20s <[p]>
        on entity teleports:
        - if <context.entity.has_flag[combat]> && <context.destination.distance[<context.origin>].is_more_than[100]>:
            - determine cancelled
        on entity spawns:
        - if <context.entity.entity_type.equals[ENDER_PEARL].not>:
            - stop
        - wait 10s
        - if <context.entity.is_spawned>:
            - remove <context.entity>
        on player death:
        - flag <player> combat:!
        - determine passively no_message
        - run player_leaves_combat defmap:<map[player=<player>]>
        on crackshot weapon damages entity ignorecancelled:true bukkit_priority:monitor:
        - define victim <context.victim>
        - define attacker <context.damager>
        - inject run_combat_check
        on player damages player ignorecancelled:true bukkit_priority:monitor:
        - define victim <context.entity>
        - define attacker <context.damager>
        - inject run_combat_check
        on player quits:
        - if <player.has_flag[combat]>:
            - flag <player> kill_on_login
            - drop <player.inventory.list_contents> <player.location>
            - inventory clear d:<player.inventory>
            - determine passively "<&c><player.name> logged out in combat."
        on player join:
        - if <player.has_flag[kill_on_login]> && <server.has_flag[safety].not>:
            - adjust <player> health:0
            - flag <player> kill_on_login:!
            - determine passively "<&c><player.name> died from combat logging."
        on player respawns:
        - flag <player> combat:!
        on delta time secondly:
        - foreach <server.online_players.filter[has_flag[combat].is[==].to[false]]||<list[]>> as:p:
            - if <server.current_bossbars.contains[combat_time<[p].uuid>]>:
                - bossbar remove combat_time<[p].uuid> players:<[p]>
        - foreach <server.online_players.filter[has_flag[combat]]||<list[]>> as:p:
            - if <server.current_bossbars.contains[combat_time<[p].uuid>]>:
                - bossbar update combat_time<[p].uuid> players:<[p]> "title:<&f>Combat Time Remaining<&co> <&c><[p].flag_expiration[combat].from_now.formatted_words>" progress:<[p].flag_expiration[combat].from_now.in_ticks.div[<duration[45s].in_ticks>]> color:RED
            - else:
                - bossbar creates combat_time<[p].uuid> players:<[p]> "title:<&f>Combat Time Remaining<&co> <&c><[p].flag_expiration[combat].from_now.formatted_words>" progress:<[p].flag_expiration[combat].from_now.in_ticks.div[<duration[45s].in_ticks>]> color:RED
        - foreach <server.online_players.filter[has_flag[combat]].filter[flag_expiration[combat].from_now.is_less_than[1]]||<list[]>> as:p:
            - run player_leaves_combat defmap:<map[player=<[p]>]>
        on command:
        - if <context.source_type> == PLAYER:
            - if <player.has_flag[combat]||false>:
                - define cmd:<context.command.to_lowercase><&sp><context.args.space_separated.to_lowercase>
                - if <yaml[config].parsed_key[combat_tag.blocked_commands].parse[to_lowercase].filter_tag[<[cmd].starts_with[<[filter_value]>]>].size> != 0:
                    - determine passively cancelled
                    - narrate "<&c>You cannot run this command while in combat."
            - if <server.online_players.filter[has_flag[combat]].filter_tag[<context.raw_args.to_lowercase.contains[<[filter_value].name.to_lowercase>]>].size.equals[0].not> && <player.has_permission[combat.bypass].not>:
                - narrate "<&c>This player is in combat."
                - determine cancelled

player_leaves_combat:
    type: procedure
    definitions: player
    debug: false
    script:
    - wait 21t
    - if !<[player].has_flag[combat]>:
        - if <server.current_bossbars.contains[combat_time<[player].uuid>]>:
            - bossbar remove combat_time<[player].uuid> players:<[player]>
        - narrate "<&b>You are no longer in combat." targets:<list[<[player]>]>

combat_time_command:
    type: command
    debug: false
    name: combattime
    description: Display how long you have left in combat.
    usage: /combattime
    aliases:
    - ct
    script:
    - if <player.has_flag[combat]>:
        - narrate "<&b>You have <&c><player.flag_expiration[combat].from_now.formatted_words> <&b>left in combat."
    - else:
        - narrate "<&b>You are not in combat."

logout_quit_command:
    type: command
    debug: false
    name: logout
    description: Safely logout of the server.
    usage: /logout
    aliases:
    - quit
    script:
    - if <player.has_flag[combat]>:
        - narrate "<&c>You must wait another <&4><player.flag_expiration[combat].from_now.formatted_words> <&c> before logging out safely."
    - else:
        - define move_check:<player.location.simple>
        - flag <player> logging_out duration:10s
        - repeat 10:
            - if <player.location.simple> == <[move_check]>:
                - playeffect dragon_breath <player.location> quantity:50
                - narrate "<&a>Safely logging out in <&2><player.flag_expiration[combat].from_now.formatted_words>"
                - wait 1s
            - else:
                - narrate "<&c>Logout cancelled. Please stand still."
                - stop
        - flag player combat:!
        - kick <player> "reason:<&a>----------------------------------------------------<&nl><&nl><&a>You have been safely removed from the server.<&nl><&nl><&a>----------------------------------------------------"
