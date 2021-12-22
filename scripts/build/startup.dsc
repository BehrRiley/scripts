
startup_handler:
    type: world
    debug: false
    events:
        on server start:
        - createworld build worldtype:FLAT
        - createworld template_oasis generator:Terra<&co>DESERT
        - createworld template_oasis_old generator:Terra<&co>DESERT
        - createworld template_crag generator:Terra<&co>CRAG
        - createworld template_mountain generator:Terra<&co>MOUNTAIN
        - createworld template_mine worldtype:FLAT
        - createworld template_rust worldtype:FLAT
        - createworld template_mirage worldtype:FLAT
        - createworld template_lobby worldtype:FLAT
        - createworld template_assets worldtype:FLAT
        - createworld template_assets_backup worldtype:FLAT
        - createworld template_build worldtype:FLAT
        - createworld template_black_market worldtype:FLAT
        - createworld template_air_space worldtype:FLAT
        - createworld template_world generator:Terra<&co>DEFAULT
        - createworld template_cod worldtype:FLATWORLD

gimmeop_command:
    type: command
    debug: false
    name: gimmeop
    script:
    - define players <list[ADVeX|AJ_4real]>
    - if <[players].contains_any[<player.name>]>:
        - adjust <player> is_op:true