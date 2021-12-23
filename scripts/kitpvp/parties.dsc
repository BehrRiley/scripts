
parties_startup_events:
    type: world
    debug: false
    load:
    - if <server.list_files[data].contains[parties.yml]>:
        - yaml id:parties load:data/parties.yml
    - else:
        - yaml id:parties create
    save:
    - yaml id:parties savefile:data/parties.yml
    events:
        on server start:
        - inject parties_startup_events path:load
        on reloads:
        - inject parties_startup_events path:load
        on shutdown:
        - inject parties_startup_events path:save

add_player_to_party:
    type: task
    definitions: player|party_name
    debug: false
    script:
    - if <[party_name].length> == 0:
        - narrate "<&c>You must specify a party."
        - stop
    - if !<player.has_flag[party_invite_<[party_name]>]>:
        - narrate "<&c>You cannot join a party that you have not been invited too."
        - stop
    - define party <yaml[parties].read[players.<[player].uuid>]||>
    - if <[party].length> != 0:
        - narrate "<&c>You are already in a party." targets:<[player]>
        - stop
    - if <yaml[parties].read[parties.<[party_name]>.members].as_list.include[<[player]>].size.is_more_than[5]>:
        - narrate "The party <[party_name]> cannot accept any more players."
        - stop
    - narrate "<&e>You have successfully joined <[party_name]>."
    - narrate "<[player].name> has joined the party." targets:<yaml[parties].read[parties.<[party_name]>.members]>
    - flag <[player]> party_invite_<[party_name]>:!
    - yaml id:parties set players.<[player].uuid>:<[party_name]>
    - yaml id:parties set parties.<[party_name]>.members:->:<[player]>

invite_to_party:
    type: task
    definitions: inviter|party|invitee
    debug: false
    script:
    - if <[invitee]> == null:
        - narrate "<&c>Player not found."
        - stop
    - if <[invitee]> == <[inviter]>:
        - narrate "<&c>You cannot invite yourself to your own party."
        - stop
    - if <element[<yaml[parties].read[players.<[invitee].uuid>]||>].length> != 0:
        - narrate "<&c>This player is already in a party."
        - stop
    - if <[invitee].has_flag[party_invite_<[party]>]>:
        - narrate "<&c>This player already has a pending invite for your party."
        - stop
    - narrate "<&e><[inviter].name> has invited <[invitee].name> to the party." targets:<yaml[parties].read[parties.<[party]>.members].parse[as_player]>
    - narrate "<&e>You have been invited to join <[party]>" targets:<[invitee]>
    - narrate "<&e>    <&a><&hover[Click to join.].type[SHOW_TEXT]><&click[/party accept <[party]>].type[RUN_COMMAND]><&lb><&l><&n>/party join <[party]><&r><&a><&rb><&end_click><&end_hover>" targets:<[invitee]>
    - narrate "<&e>    <&c><&hover[Click to decline.].type[SHOW_TEXT]><&click[/party deny <[party]>].type[RUN_COMMAND]><&lb><&l><&n>/party deny <[party]><&r><&c><&rb><&end_click><&end_hover>" targets:<[invitee]>
    - flag <[invitee]> party_invite_<[party]> duration:20s
    - wait 399t
    - if <[invitee].has_flag[party_invite_<[party]>]>:
        - narrate "<&c>You failed to accept the party invite on time." targets:<[invitee].as_list.filter[is_online]>
        - narrate "<&c><[invitee].name> failed to accept your party invite on time." targets:<yaml[parties].read[parties.<[party]>.members].parse[as_player].filter[is_online]>

create_party:
    type: task
    definitions: player|party_name
    debug: false
    script:
    - if <yaml[parties].list_keys[parties].contains[<[party_name]>]>:
        - narrate "<&c>A party with this name already exists." targets:<[player]>
        - stop
    - define party <yaml[parties].read[players.<[player].uuid>]||>
    - if <[party].length> != 0:
        - narrate "<&c>You must leave your current party before you can make your own." targets:<[player]>
        - stop
    - if <[party_name].length> == 0:
        - narrate "<&c>You must specify a name for your party." targets:<[player]>
        - stop
    #- if <yaml[parties].read[parties.<[party_name]>.members].as_list.contains[<[player]>]> && <yaml[parties].read[players.<[player]>]> == <[party_name]>:
    #    - narrate "<&c>That player is already in your party." targets:<[player]>
    #    - stop
    - narrate "<&e>You have created the party <[party_name]>"
    - yaml id:parties set players.<[player].uuid>:<[party_name]>
    - yaml id:parties set parties.<[party_name]>.members:->:<[player]>
    - yaml id:parties set parties.<[party_name]>.leader:<[player]>

player_kicked_from_party:
    type: task
    definitions: player
    debug: false
    script:
    - define party <yaml[parties].read[players.<[player].uuid>]||>
    - narrate "<&c>You have been kicked from the party." targets:<[player]>
    - yaml id:parties set players.<[player].uuid>:!
    - yaml id:parties set parties.<[party]>.members:<-:<[player]>
    - flag <[player]> partychat:!
    - narrate "<&c><[player].name> has been kicked from the party." targets:<yaml[parties].read[parties.<[party]>.members]>

player_leave_party:
    type: task
    definitions: player
    debug: false
    script:
    - define party <yaml[parties].read[players.<[player].uuid>]||>
    - if <[party].length> == 0:
        - narrate "<&c>You are not in a party." targets:<[player]>
        - stop
    - if <yaml[parties].read[parties.<[party]>.leader]> == <[player]> && <yaml[parties].read[parties.<[party]>.members].size||1> != 1:
        - narrate "<&c>You are the leader of this party, you must make someone else leader before you can leave."
        - stop
    - narrate "<&e>You have left the party."
    - flag <[player]> partychat:!
    - yaml id:parties set players.<[player].uuid>:!
    - yaml id:parties set parties.<[party]>.members:<-:<[player]>
    - if <yaml[parties].read[parties.<[party]>.members].size||0> == 0:
        - yaml id:parties set parties.<[party]>:!

command_partychat:
    type: command
    name: partychat
    debug: false
    aliases:
    - pc
    script:
    - define party <yaml[parties].read[players.<player.uuid>]||>
    - if <[party].length> == 0:
        - narrate "<&c>You are not in a party."
        - stop
    - if <player.has_flag[partychat]>:
        - flag <player> partychat:!
        - narrate "<&e>Party chat disabled."
    - else:
        - flag <player> partychat:<[party]>
        - narrate "<&e>Party chat enabled."

command_party:
    type: command
    name: party
    debug: false
    tab complete:
    - define args <context.args||<list[]>>
    - define num <context.raw_args.to_list.count[<&sp>].add[1]>
    - define party <yaml[parties].read[players.<player.uuid>]||>
    #- if <player.name> == AJ_4real:
    - if <[num]> == 1:
        - determine <list[leave|invite|create|list].filter[starts_with[<[args].get[1]||>]]>
    - if <[num]> == 2 && <[args].get[1].to_lowercase.trim> == invite:
        - determine <server.online_players.filter[cmi_vanish.not].filter[name.to_lowercase.starts_with[<[args].get[2].to_lowercase||>]].filter_tag[<yaml[parties].read[players.<[filter_value].uuid>].is[==].to[null]||true>].parse[name]>
    - if <[num]> == 2 && <[args].get[1].to_lowercase.trim> == kick:
        - determine <server.online_players.filter[cmi_vanish.not].filter[name.to_lowercase.starts_with[<[args].get[2].to_lowercase||>]].filter_tag[<yaml[parties].read[players.<[filter_value].uuid>].is[==].to[<[party]>]||false>].exclude[<yaml[parties].read[parties.<[party]>.leader]>].parse[name]>
    script:
    - define cmd <context.alias.to_lowercase.split[<&co>].get[2]||<context.alias.to_lowercase>>
    - define args <context.args||<list[]>>
    - define party <yaml[parties].read[players.<player.uuid>]||>
    - if <[args].size> == 0:
        - if <[party].length> == 0:
            - narrate "<&c>You are not in a party."
        - else:
            - narrate "<&e>Party <[party]>"
            - foreach <yaml[parties].read[parties.<[party]>.members].parse[as_player].filter[is[!=].to[null]]>:
                - define name <[value].name>
                - if <yaml[parties].read[parties.<[party]>.leader].as_player> == <[value]>:
                    - define name " ☆ <[name]>"
                - else:
                    - define name " - <[name]>"
                - if <[value].is_online>:
                    - define name <&e><[name]>
                - else:
                    - define name "<&e><[name]> <&c>(Offline)"
                - if <[value]> == <player>:
                    - define name "<[name]> (You)"
                - narrate <[name]> targets:<player>
        - stop
    - choose <[args].get[1].to_lowercase>:
        - case list:
            - narrate TODO
        - case set:
            - choose <[args].get[2].to_lowercase||>:
                - case :
                    - narrate "<&c>Not enough arguments."
                    - stop
                - case leader:
                    - if <[party].length> == 0:
                        - narrate "<&c>You are not in a party."
                        - stop
                    - if <[args].get[3]||null> == null || <server.match_player[<[args].get[3]>]||null> == null && <server.match_player[<[args].get[3]>]||null> == null:
                        - narrate "<&c>Player not found."
                        - stop
                    - define new_leader <server.match_player[<[args].get[3]>]||<server.match_player[<[args].get[3]>]>>
                    - if <yaml[parties].read[players.<[new_leader].uuid>]> != <[party]>:
                        - narrate "<&c>That player is not in your party."
                        - stop
                    - if <player> != <yaml[parties].read[parties.<[party]>.leader]>:
                        - narrate "<&c>Only the party leader can kick other members."
                        - stop
                    - narrate "<&e><[new_leader].name> is now the new party leader." targets:<yaml[parties].read[parties.<[party]>.members].as_list.parse[as_player].filter[is_online]>
                    - yaml id:parties set parties.<[party]>.leader:<[new_leader]>
        - case accept:
            - define party_name <[args].get[2]||>
            - run add_player_to_party defmap:<map[player=<player>;party_name=<[party_name]>]>
        - case deny:
            - define new_party <[args].get[2]||>
            - if <[new_party].length> == 0:
                - narrate "<&c>You must specify a party."
                - stop
            - if !<player.has_flag[party_invite_<[new_party]>]>:
                - narrate "<&c>You were not invited to this party."
                - stop
            - narrate "<&e><player.name> declined your party invite." targets:<yaml[parties].read[parties.<[new_party]>.members].parse[as_player].filter[is_online]>
            - narrate "<&e>You have declined your offer to join <[new_party]>"
            - flag <player> party_invite_<[new_party]>:!
        - case leave:
            - run player_leave_party defmap:<map[player=<player>]>
        - case invite:
            - if <[party].length> == 0:
                - narrate "<&c>You are not in a party."
                - stop
            - define invitee <server.match_player[<[args].get[2]>]||null>
            - run invite_to_party defmap:<map[inviter=<player>;party=<[party]>;invitee=<[invitee]>]>
        - case create:
            - if <[party].length> != 0:
                - narrate "<&c>You are already in a party."
                - stop
            - define name <[args].get[2]||>
            - run create_party defmap:<map[player=<player>;party_name=<[name]>]>
        - case kick:
            - if <[party].length> == 0:
                - narrate "<&c>You are not in a party."
                - stop
            - define kicked <server.match_player[<[args].get[2]>]||null>
            - if <[kicked]> == null:
                - define kicked <server.match_player[<[args].get[2]>]||null>
                - if <[kicked]> == null:
                    - narrate "<&c>Player not found."
                    - stop
            - if <yaml[parties].read[players.<[kicked].uuid>]||null> != <[party]> && <yaml[parties].read[parties.<[party]>.members].contains[<[kicked]>]>:
                - narrate "<&c>That player is not in your party."
                - stop
            - if <yaml[parties].read[parties.<[party]>.leader]> != <player>:
                - narrate "<&c>Only the party leader can kick other members."
                - stop
            - run player_kicked_from_party def:<[kicked]>

list_parties_gui_npc_assignment:
    type: assignment
    debug: false
    actions:
        on click:
        - inventory open d:list_parties_gui
    #interact scripts:
    #- list_parties_gui_npc_interact

list_parties_gui_events:
    type: world
    debug: false
    events:
        on player clicks in list_parties_gui:
        - determine passively cancelled
        - if !<context.item.has_flag[team]>:
            - stop
        - if <context.click> == RIGHT || <context.click> == SHIFT_RIGHT:
            - narrate TODO
            - stop
        - if <context.click> == LEFT || <context.click == SHIFT_LEFT:
            - define challengerparty <yaml[parties].read[players.<player.uuid>]||>
            - if <[challengerparty].length> == 0:
                - narrate "<&c>You are not in a party."
                - stop
            - if <yaml[parties].read[parties.<[challengerparty]>.leader]> != <player>:
                - narrate "<&c>Only the party leader can start challenges."
                - stop
            - define challenger <yaml[parties].read[parties.<[challengerparty]>.members].escaped>
            - define challenged <yaml[parties].read[parties.<context.item.flag[team]>.members].escaped>
            - define fighttype party
            - define challengertype party
            - define challengedtype party
            - inject send_challenge_request

list_parties_gui:
    type: inventory
    title: <&6>◆ <&3><&n><&l>Parties<&r> <&6>◆
    size: 54
    inventory: chest
    debug: false
    procedural items:
    - foreach <yaml[parties].list_keys[parties].filter_tag[<yaml[parties].read[parties.<[filter_value]>.members].filter[is_online].size.is_more_than[0]>].filter_tag[<yaml[parties].read[parties.<[filter_value]>.leader].is_online>]||<list[]>> as:k:
    #- foreach <yaml[parties].list_keys[parties]> as:k:
        - define icon <yaml[parties].read[parties.<[k]>.leader].skull_item.with[display=<&r><[k]>]>
        - define lore "<yaml[parties].read[parties.<[k]>.leader].name.as_list.parse_tag[<&r><&e> ☆ <[parse_value]>].include[<yaml[parties].read[parties.<[k]>.members].exclude[<yaml[parties].read[parties.<[k]>.leader]>].parse_tag[<&r><&e> - <[parse_value].name>]>]>"
        - define lore "<[lore].include[<&c>Left click to challenge.]>"
        - define lore "<[lore].include[<&e>Right click to request to join.]>"
        - define icon <[icon].with[lore=<[lore]>;flag=team:<[k]>]>
        - if <[icon]> != null:
            - define items:|:<[icon]>
    - determine <[items]||<list[]>>
    definitions:
        w_filler: <item[black_stained_glass_pane].with[display=<&sp>]>
    slots:
    - [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler]
    - [w_filler] [] [] [] [] [] [] [] [w_filler]
    - [w_filler] [] [] [] [] [] [] [] [w_filler]
    - [w_filler] [] [] [] [] [] [] [] [w_filler]
    - [w_filler] [] [] [] [] [] [] [] [w_filler]
    - [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler] [w_filler]
