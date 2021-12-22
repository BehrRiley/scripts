dispenser_water_cauldron:
    type: world
    debug: false
    events:
        on block dispenses item:
        - if <context.location.material.name> != dispenser:
            - stop
        - define location <context.location.add[<context.location.block_facing>]>
        - if <[location].material.name> != cauldron:
            - stop
        - if <context.item.material.name> == bucket:
            - determine passively cancelled
            - if <context.location.inventory.contains_item[water_bucket]>:
                - if <[location].material.level> != 3:
                    - adjustblock <[location]> level:3
                    - determine passively cancelled
                    - wait 1t
                    - define inv <context.location.inventory>
                    - inventory set d:<[inv]> slot:<[inv].find_item[water_bucket]> o:<item[air]>
                    - give <item[bucket]> to:<[inv]>
                    - stop
        - if <context.item.material.name> == water_bucket:
            - if <[location].material.level> != 3:
                - adjustblock <[location]> level:3
                - determine passively cancelled
                - wait 1t
                - define inv <context.location.inventory>
                - inventory set d:<[inv]> slot:<[inv].find_item[water_bucket]> o:<item[air]>
                - give <item[bucket]> to:<[inv]>