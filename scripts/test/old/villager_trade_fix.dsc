villager_trade_fix_events:
    type: world
    debug: false
    config:
        defaults:
            trading:
                enchants:
                    replace:
                        mending:
                            1:
                                first_item:
                                    material: emerald
                                    quantity: 64
                                second_item:
                                    material: book
                                    quantity: 1
                                max_uses: 1
    events:
        on player right clicks villager:
        - ratelimit <player><context.entity> 1t
        - define new_trades <context.entity.trades>
        - foreach <context.entity.trades> as:trade1:
            - define trade <[trade1]>
            - if !<[trade].result.material.name.equals[enchanted_book]>:
                - foreach next
            - define result <[trade].result>
            - define enchant <[result].enchantments.get[1]>
            - define enchant_level <[result].enchantment_map.get[<[result].enchantments.get[1]>]>
            - if !<yaml[config].contains[trading.enchants.replace.<[enchant]>.<[enchant_level]>]>:
                - stop
            - define first <item[<yaml[config].read[trading.enchants.replace.<[enchant]>.<[enchant_level]>.first_item.material]>]>
            - define first <[first].with[quantity=<yaml[config].read[trading.enchants.replace.<[enchant]>.<[enchant_level]>.first_item.quantity]>]>
            - define second <item[<yaml[config].read[trading.enchants.replace.<[enchant]>.<[enchant_level]>.second_item.material]>]>
            - define second <[second].with[quantity=<yaml[config].read[trading.enchants.replace.<[enchant]>.<[enchant_level]>.second_item.quantity]>]>
            - define trade <[trade].replace[<[trade1].inputs.get[1]>].with[<[first]>].replace[<[trade1].inputs.get[2]>].with[<[second]>].replace[max_uses=<[trade1].max_uses>].with[max_uses=<yaml[config].read[trading.enchants.replace.<[enchant]>.<[enchant_level]>.max_uses]>]>
            - define new_trades <[new_trades].replace[<[trade1]>].with[<[trade]>]>
        - adjust <context.entity> trades:<[new_trades]>