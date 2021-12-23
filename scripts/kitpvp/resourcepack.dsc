command_resourcepack:
    type: command
    name: resourcepack
    aliases:
    - rp
    tab complete:
    - if <player.has_permission[resourcepack.command.set]>:
        - define args <context.raw_args>
        - while <[args].contains_text[<&sp><&sp>]>:
            - define args <[args].replace[<&sp><&sp>].with[<&sp>]>
        - define num <[args].to_list.count[<&sp>].add[1]>
        - if <[num]> == 1:
            - determine <list[set]>
        - if <[num]> == 2:
            - determine <list[website]>
        - if <[num]> == 3:
            - determine <list[hash]>
    script:
    - if <context.args.get[1]||> == set:
        - define url <context.args.get[2]||null>
        - define hash <context.args.get[3]||null>
        - if <[url]> == null:
            - narrate "<&c>Missing resource pack URL"
            - stop
        - if <[hash]> == null:
            - narrate "<&c>Missing resource pack Hash"
            - stop
        - if !<[url].starts_with[https://]> && !<[url].starts_with[http://]>:
            - narrate "<&c>Invalid URL"
            - stop
        - if <[hash].length> != 40 || <[hash]> != <[hash].trim_to_character_set[1234567890abcdef]>:
            - narrate "<&c>Invalid Hash"
            - stop
        - flag server resourcepack_url:<[url]>
        - flag server resourcepack_hash:<[hash]>
        - resourcepack url:<server.flag[resourcepack_url]> hash:<server.flag[resourcepack_hash]>
    - narrate "<&e>Sending resource pack."
    - resourcepack url:<server.flag[resourcepack_url]> hash:<server.flag[resourcepack_hash]>
    - narrate "<&e>If you wish to download the resource pack locally, use this link: https://bit.ly/3HpuvJz"

resourcepack_events:
    type: world
    debug: false
    events:
        on player joins:
        - if <server.flag[resourcepack_url]||null> == null || <server.flag[resourcepack_hash]||null> == null:
            - stop
        - wait 5t
        - adjust <player> resource_pack:<server.flag[resourcepack_url]>

shorten_url:
    type: task
    debug: false
    definitions: url
    script:
    - define url http://download.mc-packs.net/pack/8396a35439971a3d3e7eb59e466da7eb867b70f6.zip
    - define length <[url].url_encode.to_list.size.add[4]>
    - definemap headers:
        content-length: <[length]>
        content-type: application/x-www-form-urlencoded; charset=UTF-8
    - definemap data:
        url: <[url].url_encode>
    - ~webget https://bitly.com/data/anon_shorten headers:<[headers]> data:<[data]> method:POST save:return
    #- announce <entry[return].result>
