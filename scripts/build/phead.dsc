
phead_command:
    type: command
    name: phead
    debug: false
    config:
        default:
            messages:
                player_doesnt_exist: "<&c>This player does not exist."
                no_inventory_space: "<&c>Please make room in your inventory."
            phead:
                banned_heads:
                - "CMI-Fake-Operator"
    tab complete:
    - if !<player.has_permission[]>:
        - stop
    - define str <context.raw_args>
    - while <[str].contains_text[<&sp><&sp>]>:
        - define str <[str].replace[<&sp><&sp>].with[<&sp>]>
    - define args <[str].split[<&sp>]>
    - if <[args].get[1].length||0> > 2:
        - define size <[str].split[].count[<&sp>].add[1]>
        - if <[size]> == 1:
            - determine <server.offline_players.filter[name.to_lowercase.starts_with[<context.args.get[1].to_lowercase||>]].include[<server.online_players.filter[name.to_lowercase.starts_with[<context.args.get[1].to_lowercase||>]]>].parse[name]>
    script:
    - if !<player.has_permission[phead.command]>:
        - narrate <yaml[config].parsed_key[messages.missing_permission]>
        - stop
    - if <player.money.is_less_than[250]>:
        - narrate <yaml[config].parsed_key[messages.not_enough_money]>
        - stop
    - define str <context.raw_args>
    - while <[str].contains_text[<&sp><&sp>]>:
        - define str <[str].replace[<&sp><&sp>].with[<&sp>]>
    - define args <[str].split[<&sp>]>
    - define size <[str].split[].count[<&sp>].add[1]>
    - if <[size].is_less_than[1]>:
        - narrate <yaml[config].parsed_key[messages.not_enough_args]>
        - stop
    - if <[size].is_more_than[1]>:
        - narrate <yaml[config].parsed_key[messages.too_many_args]>
        - stop
    - head from_name:<[args].get[1]>
    - define head <[head].with[display=<&b><&r><[head].display>]||null>
    - if <[head]||null> == null:
        - narrate <yaml[config].parsed_key[messages.player_doesnt_exist]>
        - stop
    - if !<player.inventory.can_fit[<[head]>]>:
        - narrate <yaml[config].parsed_key[messages.no_inventory_space]>
        - stop
    - money take from:<player> quantity:250
    - give <[head]>
