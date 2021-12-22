command_staffmode:
	type: command
    debug: false
    name: staffmode
    script:
    - define list <list[helper|mod|admin|owner]>
    - foreach <[list]> as:l:
    	- if <player.has_permission[staffmode.<[l]>]>:
        	- define rank <[l]>
    - if <[rank]||null> == null:
    	- narrate "<&c>You do not have permission for this command."
        - stop
    - if <player.has_flag[staffmode]>:
    	- if <[rank]> != owner:
            - execute as_server "lp user <player.name> parent remove <[rank]>_staffmode"
        - flag <player> staffmode:!
        - bossbar remove id:staffmode_indicator players:<player>
        - sidebar remove players:<player>
        - narrate "<&4>You have left <&l>StaffMode."
    - else:
    	- if <[rank]> != owner:
            - execute as_server "lp user <player.name> parent add <[rank]>_staffmode"
        - flag <player> staffmode
        - narrate "<&4>You have entered <&l>StaffMode."

# command_staffmode:
# 	type: command
#     debug: false
#     name: staffmode
#     script:
#     - if !<player.has_permission[staffmode]>:
#     	- narrate "<&c>You do not have permission for this command."
#         - stop
#     - if <player.has_flag[staffmode]>:
#         - flag <player> staffmode:!
#         - bossbar remove id:staffmode_indicator players:<player>
#         - sidebar remove players:<player>
#         - narrate "<&4>You have left <&l>StaffMode."
#     - else:
#         - flag <player> staffmode
#         - narrate "<&4>You have entered <&l>StaffMode."

command_debugmode:
	type: command
    debug: false
    name: debugmode
    script:
    - if !<player.has_permission[debugmode]>:
    	- narrate "<&c>You do not have permission for this command."
        - stop
    - if <player.has_flag[debugmode]>:
        - flag <player> debugmode:!
        - bossbar remove id:debugmode_indicator players:<player>
        - narrate "<&9>You have left <&l>DebugMode."
    - else:
        - flag <player> debugmode
        - narrate "<&9>You have entered <&l>DebugMode."

staffmode_events:
	type: world
    debug: false
    create_bossbars:
    - if !<server.current_bossbars.contains[staffmode_indicator]>:
        - bossbar create id:staffmode_indicator color:red title:<&l><&4>StaffMode players:<server.online_players.filter[has_flag[staffmode]]>
    - if !<server.current_bossbars.contains[debugmode_indicator]>:
        - bossbar create id:debugmode_indicator color:blue title:<&l><&9>DebugMode players:<server.online_players.filter[has_flag[debugmode]]>
    events:
        on reload scripts:
        - inject staffmode_events path:create_bossbars
        on server start:
        - inject staffmode_events path:create_bossbars
        on delta time secondly:
        - define tps <server.recent_tps.get[1].round_to[3]>
        - if <[tps].is_less_than[8]>:
        	- define tps <&c><&l><[tps]>
        - else if <[tps].is_less_than[11]>:
        	- define tps <&6><&l><[tps]>
        - else if <[tps].is_less_than[15]>:
        	- define tps <&e><&l><[tps]>
        - else:
        	- define tps <&2><&l><[tps]>
		- define tps "<&c>TPS<&co><[tps]>"
        - define uptime "<&c>Uptime: <&2><&l><server.delta_time_since_start.formatted>"
        - define tick_time "<&c>Tick Timing: <tern[<paper.tick_times.get[1].in_milliseconds.is_more_than[50]>].pass[<tern[<paper.tick_times.get[1].in_milliseconds.is_more_than[100]>].pass[<&4>].fail[<&6>]>].fail[<&2>]><&l><paper.tick_times.get[1].in_milliseconds.round_to[3]>ms"
        - define player_count "<&c>Players Online: <&2><&l><server.online_players.size>"
        - define chunk_count "<&c>Chunks Loaded: <&2><&l><server.worlds.parse[loaded_chunks.size].sum>"
        - define entity_count "<&c>Entities: <&2><&l><server.worlds.parse[entities.size].sum>"
        - define living_entity_count "<&c>Living Entities: <&2><&l><server.worlds.parse[living_entities.size].sum>"
        - define queue_count "<&c>Queues: <&2><&l><server.scripts.parse[queues.size].sum>"
        - sidebar set "title:<&4><&l>Server Status" players:<server.online_players.filter[has_flag[staffmode]]> "values:<[tps]>|<[tick_time]>|<[uptime]>|<[player_count]>|<[chunk_count]>|<[entity_count]>|<[living_entity_count]>||<[queue_count]>"
        - bossbar update id:staffmode_indicator color:red title:<&l><&4>StaffMode players:<server.online_players.filter[has_flag[staffmode]]>
        - bossbar update id:debugmode_indicator color:blue title:<&l><&9>DebugMode players:<server.online_players.filter[has_flag[debugmode]]>
        on command:
        - if <context.source_type> == PLAYER:
        	- if <player.has_permission[spy.bypass]>:
            	- stop
            - ratelimit 1t <player>
            - define cmd <context.command.to_lowercase.split[<&co>].get[2]||<context.command.to_lowercase>>
            - define args <context.args||<list[]>>
            - narrate "<&4>[Spy] <&c><player.name||<element[Console]>> <&4>-> <&c><[cmd]><&sp><[args].separated_by[<&sp>]>" targets:<server.online_players.filter[has_flag[staffmode]]>

error_handler_events:
    type: world
    debug: false
    events:
    	on entity dies:
        - if <context.entity.object_type> == player:
        	- announce to_flagged:debugmode "Teleport to death point for <context.entity.name>: <element[<&l><&lb>Death<&sp>Point<&rb>].on_click[/ex -q teleport <context.entity.location>]>"
    	on script generates error:
        - if "<context.message.starts_with[Several text tags like '&dot' or '&cm' are pointless]>":
        	- determine cancelled
        - if <context.message.ends_with[is<&sp>invalid!]> && <context.message.starts_with[Tag<&sp><&lt>inventory<&lb>]> && !<player.has_flag[debugmode]>:
        	- wait 1t
        	- inventory close
        - define "ignore_errors:|:The list_flags tag is meant for testing/debugging only. Do not use it in scripts (ignore this warning if using for testing reasons)."
        - if <context.script||null> != null && <context.line||null> != null && !<[ignore_errors].contains[<context.message>]>:
        	- if <player||null> != null:
        		- define "cause:<player.name.as_element.on_hover[Click to teleport].on_click[/ex -q teleport <player.location||null>]||None>"
        	- else:
                - define cause:None
            - announce to_console "<&c>|----------------------| <&4>Error<&c> |-----------------------|"
            - announce to_console "<&c> <context.message>"
            - announce to_console "<&c> Player: <[cause]>"
            - announce to_console "<&c> Script: <context.script.name>"
            - announce to_console "<&c> File: <context.script.filename.split[/plugins/Denizen/scripts/].get[2]>"
            - announce to_console "<&c> Line: <context.line>"
            - announce to_flagged:debugmode "<&c>|----------------------| <&4>Error<&c> |-----------------------|"
            - announce to_flagged:debugmode "<&c> <context.message>"
            - announce to_flagged:debugmode "<&c> Player: <[cause]>"
            - announce to_flagged:debugmode "<&c> Script: <context.script.name>"
            - announce to_flagged:debugmode "<&c> File: <context.script.filename.split[/plugins/Denizen/scripts/].get[2]>"
            - announce to_flagged:debugmode "<&c> Line: <context.line>"
            - foreach <context.queue.definitions.deduplicate||<list[]>> as:definition:
                - define data:<context.queue.definition[<[definition]>]>
                - define definitions:|:<proc[get_debug_info].context[<[data].escaped>|<[definition]>]>
            - announce to_flagged:debugmode "<&c> Definitions: <&l><[definitions].separated_by[<&sp><&2>|<&sp><&c><&l>]||None>"

get_debug_info:
	type: procedure
    debug: false
    definitions: data|definition
    script:
    - define data <[data].unescaped>
    - define "info:Type: <[data].object_type||Unknown>"
    - define "info:|:Script: <[data].script.name||None>"
    - choose <[data].object_type>:
        - case item:
            - define "info:|:Click to obtain."
            - define "info:|:Material: <[data].material.name||Unknown>"
            - if <[data].has_display>:
                - define "info:|:Display Name: <[data].display>"
            - if <[data].has_lore>:
                - foreach <[data].lore> as:line:
                    - define "info:|:Lore line <[loop_index]>: <[line]>"
            - determine "<&hover[<[info].separated_by[<&nl><&r>]>].type[SHOW_TEXT]><&click[/ex give<&sp><[data]>].type[RUN_COMMAND]><[definition]><&end_click><&end_hover>"
        - case location:
            - define "info:|:Click to teleport."
            - define "info:|:X=<[data].block.x>; Y=<[data].block.y>; Z=<[data].block.z>; World=<[data].world.name>"
            - define "info:|:Note: <[data].note_name||None>"
            - determine "<&hover[<[info].separated_by[<&nl><&r>]>].type[SHOW_TEXT]><&click[/ex teleport<&sp><player><&sp><[data]>].type[RUN_COMMAND]><[definition]><&end_click><&end_hover>"
        - case player:
            - define "info:|:Click to teleport."
            - define "info:|:Name: <[data].name>"
            - define "info:|:UUID: <[data].uuid>"
            - define "info:|:Health: <[data].health>; Hunger: <[data].food_level>"
            - if <[data].name.contains[<&ss>]>:
                - define "info:|:<&c>This players name contains hidden characters.<&r>"
            - determine "<&hover[<[info].separated_by[<&nl><&r>]>].type[SHOW_TEXT]><&click[/ex teleport<&sp><[data].location>].type[RUN_COMMAND]><[definition]><&end_click><&end_hover>"
        - case entity:
            - define "info:|:Click to teleport."
            - define "info:|:Entity Type: <[data].entity_type>"
            - define "info:|:UUID: <[data].uuid>"
            - define "info:|:Health: <[data].health>"
            - if <[data].name.contains[<&ss>]>:
                - define "info:|:<&c>This entitys name contains hidden characters.<&r>"
            - determine "<&hover[<[info].separated_by[<&nl><&r>]>].type[SHOW_TEXT]><&click[/ex teleport<&sp><[data].location>].type[RUN_COMMAND]><[definition]><&end_click><&end_hover>"
        - case list:
            - define "info:|:Click to copy to clipboard."
            - define "info:|:Size: <[data].size>"
            - foreach <[data]> as:v:
                - define i <[i].add[1]||1>
                - if <[i].is_more_than[50]>:
                    - foreach stop
            	- choose <[v].object_type>:
                	- case player:
                    	- define "t:<[v].name> ( <[v].uuid> )"
                    - case entity:
                    	- define "t:<player.target.scriptname||<[v].entity_type>> ( <[v].uuid> )"
                    - case item:
                        - define "t:<[v].script.name||<[v].material.name>>"
                    - case location:
                        - define "t:<tern[<[v].note_name.is_truthy>].pass[Note=<[v].note_name>; ].fail[]>X=<[v].block.x>; Y=<[v].block.y>; Z=<[v].block.z>; World=<[v].world.name>"
                    - default:
                    	- define "t:<[v]>"
                - define "info:|: - <[t]>"
            - determine <&click[<[data]>].type[COPY_TO_CLIPBOARD]><&hover[<[info].separated_by[<&nl><&r>]>].type[SHOW_TEXT]><[definition]><&end_hover><&end_click>
        - case map:
            - define "info:|:Click to copy to clipboard."
            - define "info:|:Size: <[data].size>"
            - foreach <[data].keys> as:k:
                - define i <[i].add[1]||1>
                - if <[i].is_more_than[50]>:
                    - foreach stop
                - define v <[data].get[<[k]>]>
            	- choose <[v].object_type>:
                	- case player:
                    	- define "t:<[v].name> ( <[v].uuid> )"
                    - case entity:
                    	- define "t:<player.target.scriptname||<[v].entity_type>> ( <[v].uuid> )"
                    - case item:
                        - define "t:<[v].script.name||<[v].material.name>>"
                    - case location:
                        - define "t:<tern[<[v].note_name.is_truthy>].pass[Note=<[v].note_name>; ].fail[]>X=<[v].block.x>; Y=<[v].block.y>; Z=<[v].block.z>; World=<[v].world.name>"
                    - default:
                    	- define "t:<[v]>"
                - define "info:|: <[k]> : <[t]>"
            - determine <&click[<[data]>].type[COPY_TO_CLIPBOARD]><&hover[<[info].separated_by[<&nl><&r>]>].type[SHOW_TEXT]><[definition]><&end_hover><&end_click>
        - default:
            - define "info:|:Click to copy to clipboard."
            - define "info:|:Value: <[data]>"
            - determine <&click[<[data]>].type[COPY_TO_CLIPBOARD]><&hover[<[info].separated_by[<&nl><&r>]>].type[SHOW_TEXT]><[definition]><&end_hover><&end_click>