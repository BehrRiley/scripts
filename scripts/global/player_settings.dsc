player_settings_events:
    type: world
    debug: false
    save:
    - yaml id:playersettingsdefaults savefile:data/playersettingsdefaults
    reload:
    - if !<server.list_files[data].contains[playersettingsdefaults.yml]||false>:
        - yaml create id:playersettingsdefaults
    - else:
        - yaml id:playersettingsdefaults load:data/playersettingsdefaults.yml
    - foreach <server.scripts> as:s:
        - if <[s].data_key[config.playersettings]||null> != null:
            - foreach <[s].list_deep_keys[config.playersettings]> as:k:
                - if !<yaml[playersettingsdefaults].contains[<[k]>]>:
                    - define v <[s].data_key[config.playersettings.<[k]>]>
                    - if <[v].object_type.to_lowercase> == list:
                        - foreach <[v]> as:i:
                            - yaml id:playersettingsdefaults set <[k]>:|:<[i]>
                    - else:
                        - yaml id:playersettingsdefaults set <[k]>:<[v]>
    - yaml id:playersettingsdefaults savefile:data/playersettingsdefaults.yml
    events:
        on reload scripts:
        - inject player_settings_events path:reload
        on server start:
        - inject player_settings_events path:reload
        - foreach <yaml[config].read[startup_commands]>:
            - execute as_server <[value]>
        on player quits:
        - yaml id:player_<player.uuid> savefile:data/players/<player.uuid>.yml
        - yaml id:player_<player.uuid> unload
        on player join:
        - if <server.list_files[data/players].contains[<player.uuid>]>:
            - yaml id:player_<player.uuid> load:data/players/<player.uuid>.yml
        - else:
            - yaml id:player_<player.uuid> create
        - foreach <yaml[playersettingsdefaults].list_deep_keys[]>:
            - if !<player.has_flag[playersettings.<[value]>]>:
                - flag <player> playersettings.<[value]>:<yaml[playersettingsdefaults].read[<[value]>]>

player_settings_choose_enemy_color_inventory:
    type: inventory
    inventory: chest
    size: 9
    gui: true
    title: <&l><&b>TODO
    procedural items:
    - determine <list[]>
    definitions:
        ui: <item[light_gray_stained_glass_pane].with[display=<&sp>]>
    slots:
        - [] [] [] [] [] [] [] [] []
