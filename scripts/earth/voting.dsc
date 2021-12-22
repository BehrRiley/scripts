command_topvotes:
  type: command
  description: shows top voters
  usage: /topvotes
  name: topvotes
  debug: false
  script:
  - inventory open d:top_voters_gui

proc_get_mission_item_from_tier:
  type: procedure
  debug: false
  definitions: tier
  data:
    1:
      e: 80
      m: 20
    2:
      e: 65
      m: 30
      h: 5
    3:
      e: 54
      m: 30
      h: 15
      i: 1
    4:
      e: 30
      m: 35
      h: 25
      i: 10
    5:
      e: 10
      m: 45
      h: 30
      i: 15
  script:
  - define map <script.data_key[data.<[tier].if_null[1]>]>
  - foreach <[map]>:
    - define pool:|:<[key].repeat_as_list[<[value]>]>
  - choose <[pool].random>:
    - case e:
      - determine <proc[get_mission_item].context[easy]>
    - case m:
      - determine <proc[get_mission_item].context[medium]>
    - case h:
      - determine <proc[get_mission_item].context[hard]>
    - case i:
      - determine <proc[get_mission_item].context[insane]>

top_voters_gui:
  type: inventory
  inventory: chest
  title: Voting Statistics
  gui: true
  debug: false
  definitions:
    ph: <item[black_stained_glass_pane].with[display=<&f>]>
  procedural items:
  - define voters <server.players_flagged[votes.month.<util.time_now.start_of_month.epoch_millis.div[1000]>].sort_by_number[flag[votes.month.<util.time_now.start_of_month.epoch_millis.div[1000]>.service].values.sum].reverse>
  - define items <list[]>
  - foreach <[voters].get[1].to[10]> as:p:
    - define lore:<list[]>
    - define icon <item[player_head].with[skull_skin=<[p].flag[skin.skull]>;display=<&e><[p].name>]>
    - define "lore:|:<&e>Total Votes This Month: <[p].flag[votes.month.<util.time_now.start_of_month.epoch_millis.div[1000]>.service].values.sum>"
    - define icon <[icon].with[lore=<[lore]>]>
    - define items:|:<[icon]>
  - determine <[items]>
  slots:
  - [ph] [ph] [ph] [ph] [ph] [ph] [ph] [ph] [ph]
  - [ph] [ph] [] [] [] [] [] [ph] [ph]
  - [ph] [ph] [] [] [] [] [] [ph] [ph]
  - [ph] [ph] [ph] [ph] [ph] [ph] [ph] [ph] [ph]

command_vote_stats:
  type: command
  description: shows vote stats
  usage: /votestats
  debug: false
  name: votestats
  permission: votestats
  script:
  - inventory open d:vote_stats_gui

vote_stats_gui:
  type: inventory
  inventory: chest
  title: Voting Statistics
  gui: true
  debug: false
  slots:
  - [] [] [] [] [] [] [] [] []
  - [] [] [vote_stats_gui_icon_total_votes] [vote_stats_gui_icon_biggest_voter] [vote_stats_gui_icon_months_biggest_voter] [vote_stats_gui_icon_most_used_website] [vote_stats_gui_icon_months_most_used_website] [] []
  - [] [] [] [] [vote_stats_gui_icon_total_votes_this_month] [] [] [] []
  - [] [] [] [] [] [] [] [] []

vote_stats_gui_icon_total_votes:
  type: item
  material: chest
  debug: false
  data:
    tag: <server.players_flagged[votes.service].parse[flag[votes.service].values.sum].sum||Unknown>
  display name: <&6>Total Votes<&co> <&e><script.parsed_key[data.tag]||Unknown>

vote_stats_gui_icon_biggest_voter:
  type: item
  material: gold_ingot
  debug: false
  data:
    tag: <server.players_flagged[votes.service].sort_by_number[flag[votes.service].values.sum].last.name||Unknown>
  display name: <&6>Biggest Voter<&co> <&e><script.parsed_key[data.tag]||Unknown>

vote_stats_gui_icon_months_biggest_voter:
  type: item
  material: diamond
  debug: false
  data:
    tag: <server.players_flagged[votes.month.<util.time_now.start_of_month.epoch_millis.div[1000]>].sort_by_number[flag[votes.month.<util.time_now.start_of_month.epoch_millis.div[1000]>.service].values.sum].last.name||Unknown>
  display name: <&6>Months Biggest Voter<&co> <&e><script.parsed_key[data.tag]||Unknown>

proc_most_used_website:
  type: procedure
  debug: false
  script:
  - define websites <map[]>
  - foreach <server.players_flagged[votes.service]> as:p:
    - define websites <[websites].include[<[p].flag[votes.service]>]>
  - define highest <[websites].sort_by_value>
  - determine <[highest].keys.last||Unknown>

proc_most_used_website_this_month:
  type: procedure
  debug: false
  script:
  - define websites <map[]>
  - define month <util.time_now.start_of_month.epoch_millis.div[1000]>
  - foreach <server.players_flagged[votes.month.<[month]>.service]> as:p:
    - define websites <[websites].include[<[p].flag[votes.month.<[month]>.service]>]>
  - define highest <[websites].sort_by_value>
  - determine <[highest].keys.last||Unknown>

vote_stats_gui_icon_most_used_website:
  type: item
  material: iron_ingot
  debug: false
  data:
    tag: <proc[proc_most_used_website]||Unknown>
  display name: <&6>Most Used Website<&co> <&e><script.parsed_key[data.tag]>

vote_stats_gui_icon_months_most_used_website:
  type: item
  material: coal
  debug: false
  data:
    tag: <proc[proc_most_used_website_this_month]||Unknown>
  display name: <&6>Most Used Website This Month<&co> <&e><script.parsed_key[data.tag]>

vote_stats_gui_icon_total_votes_this_month:
  type: item
  material: ender_chest
  debug: false
  data:
    tag: <server.players_flagged[votes.month.<util.time_now.start_of_month.epoch_millis.div[1000]>.service].parse[flag[votes.month.<util.time_now.start_of_month.epoch_millis.div[1000]>.service].values.sum].sum||Unknown>
  display name: <&6>Total Votes This Month<&co> <&e><script.parsed_key[data.tag]>

voting_startup:
  type: world
  debug: false
  #save:
  #- yaml id:player_votes savefile:data/player_votes.yml
  #- yaml id:voting_rewards savefile:data/voting_rewards.yml
  load:
  - if <server.list_files[data].contains[voting_rewards.yml]>:
      - yaml id:voting_rewards load:data/voting_rewards.yml
  - else:
      - yaml id:voting_rewards create
  events:
    on reload scripts:
    - inject voting_startup path:load
    on server start:
    - inject voting_startup path:load

voting_events:
  type: world
  debug: false
  events:
    on votifier vote:
      - define service <context.service.replace_text[.].with[_]>
      - if <player[<context.username>]||null> == null:
        - stop
      - define player <player[<context.username>]>
      - adjust <queue> linked_player:<[player]>
      - flag <[player]> voted duration:24h
      - flag <[player]> votes.service.<[service]>:+:1
      - flag <[player]> votes.month.<util.time_now.start_of_month.epoch_millis.div[1000]>.service.<[service]>:+:1
      - define total_votes <player.flag[votes.service].keys.parse_tag[<player.flag[votes.service.<[parse_value]>]>].sum||0>
      - define tier <yaml[voting_rewards].list_keys[tiers].filter_tag[<yaml[voting_rewards].read[tiers.<[filter_value]>].is_less_than_or_equal_to[<[total_votes]>]>].highest>
      - foreach <yaml[voting_rewards].list_keys[rewards.tier.<[tier]>.every]> as:k:
        - if <[total_votes].mod[<[k]>]> == 0:
          - if <yaml[voting_rewards].read[rewards.tier.<[tier]>.every.<[k]>.message]||null> != null:
            - define message <proc[colorize].context[<yaml[voting_rewards].read[rewards.tier.<[tier]>.every.<[k]>.message].separated_by[<&nl>]>|<[player]>].replace_text[<&pc>player_tier<&pc>].with[<[tier]>].replace_text[<&pc>service<&pc>].with[<context.service>]||null>
            - if <[message]> != null:
              - narrate <[message]> targets:<[player]>
          - if <yaml[voting_rewards].read[rewards.tier.<[tier]>.every.<[k]>.announcement]||null> != null:
            - define announcement <proc[colorize].context[<yaml[voting_rewards].read[rewards.tier.<[tier]>.every.<[k]>.announcement].separated_by[<&nl>]||null>|<[player]>].replace_text[<&pc>player_tier<&pc>].with[<[tier]>].replace_text[<&pc>service<&pc>].with[<context.service>]||null>
            - if <[announcement]> != null:
              - announce <[announcement]>
        - foreach <yaml[voting_rewards].read[rewards.tier.<[tier]>.every.<[k]>.commands]> as:command:
              - execute as_server <[command].replace_text[<&pc>player_name<&pc>].with[<[player].name>]>
      - flag server votes:+:1
      - foreach <yaml[voting_rewards].list_keys[rewards.party.every]> as:k:
        - if <server.flag[votes].mod[<[k]>]> == 0:
            - foreach <server.online_players.filter[has_flag[voted]]> as:pl:
              - foreach <yaml[voting_rewards].read[rewards.party.every.<[k]>.commands.players_who_voted]> as:cmd:
                  - execute as_server <[cmd].replace_text[<&pc>player_name<&pc>].with[<[pl].name>]>
                  - define message <proc[colorize].context[<yaml[voting_rewards].read[rewards.party.every.<[k]>.message.players_who_voted].separated_by[<&nl>]>|<[pl]>]||null>
                  - narrate <[message]> targets:<[pl]>
      - yaml id:player_<[player].uuid> savefile:data/players/<[player].uuid>.yml
