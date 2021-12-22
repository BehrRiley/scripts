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
        on villager acquires trade:
        - if !<context.trade.result.material.name.equals[enchanted_book]>:
            - stop
        - define result <context.trade.result>
        - define enchant <[result].enchantments.get[1]>
        - define enchant_level <[result].enchantment_map.get[<[result].enchantments.get[1]>]>
        - if !<yaml[config].contains[trading.enchants.replace.<[enchant]>.<[enchant_level]>]>:
            - stop
        - define first <item[<yaml[config].read[trading.enchants.replace.<[enchant]>.<[enchant_level]>.first_item.material]>]>
        - define first <[first].with[quantity=<yaml[config].read[trading.enchants.replace.<[enchant]>.<[enchant_level]>.first_item.quantity]>]>
        - define second <item[<yaml[config].read[trading.enchants.replace.<[enchant]>.<[enchant_level]>.second_item.material]>]>
        - define second <[first].with[quantity=<yaml[config].read[trading.enchants.replace.<[enchant]>.<[enchant_level]>.second_item.quantity]>]>
        - define trade <context.trade>
        - adjust <[trade]> inputs:<[first]>|<[second]>
        - adjust <[trade]> max_uses:<yaml[config].read[trading.enchants.replace.<[enchant]>.<[enchant_level]>.max_uses]>
        - determine <[trade]>
        on player trades with merchant:
        - if <context.trade.result.enchantment_types.parse[name].contains[mending]>:
            - if <context.merchant.has_flag[trading.cooldown.mending]>:
                - narrate "<&c>You cannot use this trade for <context.merchant.flag_expiration[trading.cooldown.mending].from_now.formatted>"
                - determine cancelled
            - flag <context.merchant> trading.cooldown.mending expire:1d