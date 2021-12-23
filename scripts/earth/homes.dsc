command_sethome:
    type: command
    debug: false
    name: sethome
    script:
    - if <player.location.town||null1> != <player.town||null2>:
        - narrate "<&c>You can only set a home in your own town."
        - stop
    - flag <player> home.location:<player.location.center.below[0.5].with_yaw[<player.location.yaw>].with_pitch[<player.location.pitch>]>
    - narrate "<&e>You set your home; to teleport here, use '/home'"

command_home:
    type: command
    debug: false
    name: home
    script:
    - if <player.flag[home.location].as_location.exists>:
        - if <player.flag[home.location].as_location.town||null1> == <player.town||null2>:
            - teleport <player> <player.flag[home.location]>
        - else:
            - narrate "<&c>You cannot teleport to your home because it is in a different town."
    - else:
        - narrate "<&c>You have not set a home yet; to do so, type '/sethome'"
