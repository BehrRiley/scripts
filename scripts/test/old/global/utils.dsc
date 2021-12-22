
colorize:
	type: procedure
    definitions: text|player|location
    debug: false
    placeholders:
    	player:
	    	player_name: <[player].name>
            player_money: <[player].money||0>
            player_money_formatted: <[player].money.format_number||0>
            player_town_name: <[player].town.name||None>
            player_nation_name: <[player].nation.name||None>
            player_ping: <[player].ping||-1>
        location:
        	loc_x: <[location].x>
        	loc_z: <[location].z>
        	world_name: <[location].world.name>
        global:
        	votes_until_party: <element[100].sub[<server.flag[votes].mod[100]>]>
        	bungee_total: <yaml[server_info].read[players].as_list.size||0>
        	online_players: <server.online_players.filter_tag[<[filter_value].cmi_vanish.not||true>].size>
            server_max_players: <server.max_players>
    script:
    - if <element[<[player]||null>].equals[null]> && !<element[<player||null>].equals[null]>:
    	- define player <player>
    - if !<element[<[player]||null>].equals[null]>:
    	- if <element[<[location]||null>].equals[null]>:
        	- define location <[player].location>
    	- foreach <script.list_keys[placeholders.player]> as:k:
        	- define text <[text].replace[<&pc><[k]><&pc>].with[<script.data_key[placeholders.player.<[k]>].parsed>]||>
    - if !<element[<[location]||null>].equals[null]>:
    	- foreach <script.list_keys[placeholders.location]> as:k:
        	- define text <[text].replace[<&pc><[k]><&pc>].with[<script.data_key[placeholders.location.<[k]>].parsed>]||>
    - foreach <script.list_keys[placeholders.global]> as:k:
        - define text <[text].replace[<&pc><[k]><&pc>].with[<script.data_key[placeholders.global.<[k]>].parsed>]||>
    - determine <[text].parse_color[&]>