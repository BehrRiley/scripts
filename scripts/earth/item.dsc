remove_incendium_items:
    type: world
    debug: false
    events:
        on player opens inventory:
        - if <player.inventory.list_contents.filter[all_raw_nbt.keys.contains[incendium]].size.equals[0].not||false>:
            - inventory exclude d:<player.inventory> origin:<player.inventory.list_contents.filter[all_raw_nbt.keys.contains[incendium]]>
        - if <context.inventory.list_contents.filter[all_raw_nbt.keys.contains[incendium]].size.equals[0].not||false>:
            - inventory exclude d:<context.inventory> origin:<context.inventory.list_contents.filter[all_raw_nbt.keys.contains[incendium]]>
