
fixes_events:
    type: world
    debug: false
    config:
        defaults:
            enderpearl:
                cooldown: 20s
                damage_when_teleported: 2
            lagcontrol:
                redstone:
                    min_time_between_pulse: 1s
                    number_before_removal: 10
                entities:
                    maximum_per_chunk: 50
            offhand:
            	disallow:
                - AK47
                - SPAS12
    events:
    	on tab complete:
        - determine <context.completions.exclude[<context.completions.filter[as_player.cmi_vanish]>]>
    	on player swaps items:
        - if <yaml[config].read[offhand.disallow].parse[to_uppercase].contains[<context.offhand.crackshot_weapon.to_uppercase||<context.offhand.script.name||<context.offhand.material.name>>>]>:
        	- determine cancelled
    	on entity damaged ignorecancelled:true:
        - if <player.name||null> == SuperTNT20 && <player.world.name.starts_with[arena]||false>:
        	- determine cancelled:false
    	on player joins:
        - determine NONE
        on player quits:
        - determine NONE
        on player receives message:
        - if <context.message.strip_color.starts_with[<&sp><&sp>Eg:<&sp>/tr<&sp>]>:
            - determine MESSAGE:<context.message.replace[/tr].with[/trs]>
        on redstone recalculated:
        - define loc <context.location.center>
        - ratelimit <[loc]> 2t
        - flag <[loc]> redstone:<[loc].flag[redstone].add[1]||1> duration:<yaml[config].read[lagcontrol.redstone.min_time_between_pulse].as_duration||<duration[1s]>>
        - if <[loc].has_flag[redstone]>:
            - define num <[loc].flag[redstone]>
            #- announce <[loc].material><&sp><[num]>
            - if <[num].is_more_than[<yaml[config].read[lagcontrol.redstone.number_before_removal]||10>]>:
                - drop <[loc].material.name> <[loc]>
                - wait 1t
                - modifyblock <[loc]> air
                - flag <[loc]> redstone:!
        on delta time minutely:
        - define limit <yaml[config].read[lagcontrol.entities.maximum_per_chunk]||50>
        - define removed 0
        - foreach <server.worlds> as:w:
            - foreach <[w].loaded_chunks> as:c:
                - define a <[c].living_entities.size>
                - if <[a].is_more_than[<[limit]>]>:
                    - remove <[c].living_entities.random[<[a].sub[<[limit]>]>]>
                    - define removed:<[removed].add[<[a].sub[<[limit]>]>]>
        - if <[removed].is_more_than[0]>:
            - announce "<&c><[removed]> <&e>entities were removed from crowded chunks."
        on ender_pearl spawns:
        - define pl <context.location.find.players.within[0.1].get[1]||null>
        - if <[pl]> != null:
        	- adjust <queue> linked_player:<[pl]>
        	- itemcooldown ender_pearl duration:<yaml[config].read[enderpearl.cooldown]>
        on player clicks block:
        - if <player.item_in_hand.material.name.to_lowercase> == ender_pearl || <player.item_in_offhand.material.name.to_lowercase> == ender_pearl:
            - if <player.item_in_hand.material.name.to_lowercase> == ender_pearl:
                - define num1 <player.item_in_hand.quantity>
            - if <player.item_in_offhand.material.name.to_lowercase> == ender_pearl:
                - define num1 <player.item_in_offhand.quantity>
            - wait 1t
            - if <player.item_in_hand.material.name.to_lowercase> == ender_pearl:
                - define num2 <player.item_in_hand.quantity>
            - if <player.item_in_offhand.material.name.to_lowercase> == ender_pearl:
                - define num2 <player.item_in_offhand.quantity>
            - if <[num1]||1> != <[num2]||2>:
                - itemcooldown ender_pearl duration:<yaml[config].read[enderpearl.cooldown]>
        on crackshot player fires projectile:
        - if <player.is_sprinting>:
            - determine BULLET_SPREAD:<context.bullet_spread.mul[2]>
        - if <player.is_sneaking>:
            - determine BULLET_SPREAD:<context.bullet_spread.div[3]>
        on entity damaged:
        - if <context.damager.fallingblock_material.name.contains_text[dripstone]||false>:
            - determine cancelled
        - if <context.projectile.entity_type||null> == ender_pearl:
            - determine <yaml[config].read[enderpearl.damage_when_teleported]>
        on entity teleports:
        - if <player||null> != null:
            - if <player.has_flag[going_home]>:
                - if <context.destination.town> != <player.town>:
                    - determine passively cancelled
        on player consumes item:
        - if <context.item.potion_base.starts_with[STRENGTH]||false>:
            - determine cancelled
        on potion splash ignore_cancelled:true:
        - if <context.potion.potion_base.starts_with[INSTANT_DAMAGE,2]||false> || <context.potion.potion_base.starts_with[STRENGTH]||false>:
            - determine cancelled
        - else:
        	- determine cancelled:false
        on lingering potion splash:
        - determine cancelled
        on entity death:
        - determine <context.drops.filter[material.name.is[!=].to[TRIDENT]]>
        on command:
        - define cmd <context.command.to_lowercase.split[<&co>].get[2]||<context.command.to_lowercase>>
        - define args <context.args||<list[]>>
        - if <[cmd]> == ?:
        	- determine cancelled
        - if <[cmd].to_lowercase||> == cmi:
            - if <[args].get[1].to_lowercase||> == nick:
                - wait 1t
                - if <player.display_name||<player.name>> != <player.name>:
                	- adjust <player> player_list_name:<proc[colorize].context[<player.chat_prefix>]||<player.chat_prefix>><&r>~<player.display_name>
                - else:
                	- adjust <player> player_list_name:<proc[colorize].context[<player.chat_prefix>]||<player.chat_prefix>><&r><player.display_name>
        - if <[cmd]> == vulcan && <[args].get[1]||> == clickalert:
        	- if <player.has_permission[minecraft.command.gamemode]>:
            	- adjust <player> gamemode:spectator
        - if <[cmd]> == "cmi":
            - define cmd <context.args.get[1].to_lowercase||<[cmd]>>
            - define args <[args].remove[1]>
        - if <[cmd]> == "ac":
            - determine passively cancelled
            - execute as_player "alliancechat"
        - if <[cmd]> == "n" || <[cmd]> == "nation":
            - if <[args].get[1]||null> == "set":
                - if <[args].get[2]||null> == "spawn":
                    - if !<player.town_immunity.is_less_than[0s]>:
                        - define before <player.town.spawn>
                        - if <[args].get[3]||null> != "confirm":
                            - narrate "<&c>[!] Moving your nation's spawn will remove the capitals siege immunity. Are you sure you want to do this?<&nl><element[<&a><&lb>Confirm<&rb><&r>].on_click[/nation set spawn confirm]>"
                            - determine passively cancelled
                        - else:
                            - if <player.has_permission[towny.rank.nation.coking]> || <player.has_permission[towny.rank.nation.king]>:
                                - if <player.location.town||null1> == <player.town||null2>:
                                    - wait 1t
                                    - if <[before]> != <player.town.spawn>:
                                        - execute as_server "swa siegeimmunity town <player.location.town.name> 0"
                                        - narrate "<&c>Due to your nations capitals spawn being changed, your towns siege immunity has been removed." targets:<player.town.residents.filter[is_online]>

        - if <[cmd]> == "rename" || <[cmd]> == "itemname":
            - if !<player.has_permission[cmi.command.itemname]>:
                - stop
            - if <[args].size> == 0:
                - stop
            - if <player.item_in_hand.material.name> == air:
                - determine passively cancelled
            - if <player.money.is_less_than[250]>:
                - determine passively cancelled
                - narrate "<&c>You do not have enough money for that command.<&nl>You have <player.formatted_money>, You need $250"
            - define name <player.item_in_hand.display||null1>
            - wait 1t
            - if <[name]> != <player.item_in_hand.display||null2>:
                - money take quantity:250 from:<player>
                - narrate "<&e>You now have <player.formatted_money>."
        - if <[cmd]> == home:
            - flag <player> going_home duration:1s
        - define blocked_commands:<list[denizen<&co>exs|denizen<&co>ex|ex|lp|luckperms]>
        - if <[blocked_commands].contains_any[<[cmd]>].size.is[!=].to[0]||false>:
            - if <context.source_type> != SERVER && <player.uuid> != 2d77f2e6-ccc8-4642-933e-62c83d1b501b:
                - determine passively cancelled
                - narrate "<&c>This command has been restricted."
        - if <[cmd]> == "lore":
            - if !<player.has_permission[lores.lore]>:
                - stop
            - if <context.args.get[1]||null> == null:
                - stop
            - if !<list[add|set|insert|delete].contains[<context.args.get[1].to_lowercase>]>:
                - stop
            - if <player.item_in_hand.material.name> == air:
                - determine passively cancelled
            - if <player.money.is_less_than[100]>:
                - determine passively cancelled
                - narrate "<&c>You do not have enough money for that command.<&nl>You have <player.formatted_money>, You need $100"
            - define lore <player.item_in_hand.lore||null1>
            - wait 1t
            - if <[lore]> != <player.item_in_hand.lore||null1>:
                - money take quantity:100 from:<player>
                - narrate "<&e>You now have <player.formatted_money>."

trs_command:
    type: command
    name: trs
    debug: false
    tab complete:
    - define str <context.raw_args>
    - while <[str].contains_text[<&sp><&sp>]>:
        - define str <[str].replace[<&sp><&sp>].with[<&sp>]>
    - define size <[str].split[].count[<&sp>].add[1]>
    - if <[size]> == 1:
        - determine <list[survey|nationcollect|towncollect].filter[starts_with[<context.args.get[1].to_lowercase||>]]>
    script:
    - execute as_player "townyresources <context.args.separated_by[<&sp>]>"

pm_command:
    type: command
    name: pm
    debug: false
    tab complete:
    - if !<player.has_permission[cmi.command.msg]>:
        - stop
    - define str <context.raw_args>
    - while <[str].contains_text[<&sp><&sp>]>:
        - define str <[str].replace[<&sp><&sp>].with[<&sp>]>
    - define size <[str].split[].count[<&sp>].add[1]>
    - if <[size]> == 1:
        - determine <server.online_players.filter[name.to_lowercase.starts_with[<context.args.get[1].to_lowercase||>]].parse[name]>
    script:
    - execute as_player "cmi msg <context.args.separated_by[<&sp>]>"
