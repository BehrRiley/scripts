command_tree:
	type: command
    debug: true
    name: maketree
    script:
    - if <schematic.list.parse[to_lowercase].contains[<context.args.get[1].to_lowercase>]>:
    	- narrate "schematic already exists"
        - stop
    - schematic create <player.we_selection> noair <player.location> name:<context.args.get[1]>
    - schematic name:<context.args.get[1]> save filename:<context.args.get[1]>
    - narrate "saved"
    - foreach <player.we_selection.blocks[!air]>:
        - modifyblock <[value]> air

list_files_recursively:
    type: procedure
    debug: false
    definitions: path
    script:
    - define todo:<server.list_files[<[path]||>]>
    - define files <list[]>
    - while <[todo].size.equals[0].not>:
        - foreach <[todo]> as:p:
            - define todo <[todo].exclude[<[p]>]>
            - foreach <server.list_files[<[path]>/<[p]>]> as:f:
                - if <server.list_files[<[path]>/<[p]>/<[f]>].exists>:
                    - define todo:|:<[p]>/<[f]>
                - else:
                    - define files:|:<[p]>/<[f]>
    - determine <[files]>

schematics_events:
    type: world
    debug: false
    events:
        on server start:
        - foreach <proc[list_files_recursively].context[schematics]> as:schem:
            - schematic name:<[schem].replace[.schem].with[]> load filename:<[schem].replace[.schem].with[]>

command_pastetree:
    type: command
    debug: false
    name: pastetree
    script:
    - stop
    - define schem spruce/large/1
    - define loc <player.location.block>
    - define origin <schematic[<[schem]>].origin.with_world[<[loc].world>]>
    - while <schematic[<[schem]>].block[<[origin]>].name.equals[air]>:
        - define origin <[origin].find_blocks.within[3].filter_tag[<schematic[<[schem]>].block[<[filter_value]>].name.equals[air].not>].random>
    - define blocks <list[<[origin].with_world[<[loc].world>]>]>
    - define done <list[]>
    - while <[blocks].size.equals[0].not>:
        - define rel <list[]>
        - foreach <[blocks].exclude[<[done]>].filter[add[<[loc]>].material.name.equals[air]]> as:b:
            - define done:|:<[b]>
            - define material <schematic[<[schem]>].block[<[b]>]>
            - modifyblock <[loc].add[<[b]>]> <[material]>
            # - define rel:|:<[b].relative[1,0,0]>
            # - define rel:|:<[b].relative[-1,0,0]>
            # - define rel:|:<[b].relative[0,1,0]>
            # - define rel:|:<[b].relative[0,-1,0]>
            # - define rel:|:<[b].relative[0,0,1]>
            # - define rel:|:<[b].relative[0,0,-1]>
            - if <schematic[<[schem]>].block[<[b].relative[1,0,0]>].name.equals[air].not||false>:
                - define rel:|:<[b].relative[1,0,0]>
            - if <schematic[<[schem]>].block[<[b].relative[-1,0,0]>].name.equals[air].not||false>:
                - define rel:|:<[b].relative[-1,0,0]>
            - if <schematic[<[schem]>].block[<[b].relative[0,1,0]>].name.equals[air].not||false>:
                - define rel:|:<[b].relative[0,1,0]>
            - if <schematic[<[schem]>].block[<[b].relative[0,-1,0]>].name.equals[air].not||false>:
                - define rel:|:<[b].relative[0,-1,0]>
            - if <schematic[<[schem]>].block[<[b].relative[0,0,1]>].name.equals[air].not||false>:
                - define rel:|:<[b].relative[0,0,1]>
            - if <schematic[<[schem]>].block[<[b].relative[0,0,-1]>].name.equals[air].not||false>:
                - define rel:|:<[b].relative[0,0,-1]>
            - define i <[i].add[1]||1>
            - if <[i].is_more_than[3]>:
                # - wait 1t
                - define i 0
        	- wait 1t
        - define blocks <[rel].deduplicate.exclude[<[done]>]>