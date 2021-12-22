
startup_handler:
    type: world
    debug: false
    events:
        on server start:
        - yaml id:server_info create
        - createworld build worldtype:FLAT
        - createworld template_oasis generator:Terra<&co>DESERT
        - createworld template_crag generator:Terra<&co>CRAG
        - createworld template_mountain generator:Terra<&co>MOUNTAIN
        - createworld template_mine worldtype:FLAT
        - createworld template_railroad worldtype:FLAT
        - createworld template_mirage worldtype:FLAT
        - createworld template_bunker worldtype:FLAT
        - createworld template_air_space worldtype:FLAT
        - createworld template_black_market worldtype:FLAT
        - createworld template_test worldtype:FLAT