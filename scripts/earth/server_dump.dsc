server_dump:
  type: task
  debug: false
  definitions: type
  script:
    - if <server.has_file[server_dump.txt]>:
      - adjust server delete_file:server_dump.txt
    - log "Server Dump Information<n><n>" file:plugins/Denizen/server_dump.txt
    # Server TPS
    - log "Recent TPS: <server.recent_tps.separated_by[,<&sp>]>" type:none file:plugins/Denizen/server_dump.txt
    # Loaded Chunks per World
    - log "<n>Chunks Loaded per World" type:none file:plugins/Denizen/server_dump.txt
    - foreach <server.worlds> as:world:
      - log "<[world].name> - <[world].loaded_chunks.size>" type:none file:plugins/Denizen/server_dump.txt
    # Player Worlds
    - log "<n>Players per World" type:none file:plugins/Denizen/server_dump.txt
    - foreach <server.online_players> as:player:
      - flag server entity_counts.<[player].location.world.name>:+:1
    - foreach <server.flag[entity_counts]> key:key as:value:
      - log "<[key]> - <[value]>" type:none file:plugins/Denizen/server_dump.txt
    - flag server entity_counts:!
    # Entities per World
    - log "<n>Entities per World" type:none file:plugins/Denizen/server_dump.txt
    - foreach <server.worlds> as:world:
      - foreach <[world].entities> as:entity:
        - flag server entity_counts.<[entity].entity_type>:+:1
    - foreach <server.flag[entity_counts]> key:key as:value:
      - log "<[key]> - <[value]>" type:none file:plugins/Denizen/server_dump.txt
    - flag server entity_counts:!
    # Entities per Chunk
    - log "<n>Entities per Chunk (over 10)" type:none file:plugins/Denizen/server_dump.txt
    - foreach <server.worlds> as:world:
      - foreach <[world].entities> as:entity:
        - flag server entity_counts.<[entity].location.chunk>:+:1
    - foreach <server.flag[entity_counts]> key:key as:value:
      - if <[value]> > 10:
        - log "<[key]> - <[value]>" type:none file:plugins/Denizen/server_dump.txt
    - flag server entity_counts:!
    - foreach <server.worlds> as:world:
      - foreach <[world].entities[dropped_item]> as:item_entity:
        - flag server entity_counts.<[item_entity].item.material.name>:+:1
    - foreach <server.flag[entity_counts]> key:key as:value:
      - if <[value]> > 10:
        - log "<[key]> - <[value]>" type:none file:plugins/Denizen/server_dump.txt
    # Event Statistics
    - log "<n>Event Statistics:<n><n>" type:none file:plugins/Denizen/server_dump.txt
    - log <util.event_stats.strip_color> type:none file:plugins/Denizen/server_dump.txt