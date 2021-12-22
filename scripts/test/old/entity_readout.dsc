entity_readout:
  type: task
  debug: false
  definitions: type
  script:
  - if <[type]> == count:
    - foreach <server.worlds> as:world:
      - foreach <[world].entities> as:entity:
        - flag server entity_counts.<[entity].entity_type>:+:1
    - foreach <server.flag[entity_counts]> key:key as:value:
      - narrate "<[key]> - <[value]>"
    - flag server entity_counts:!
  - else if <[type]> == location:
    - foreach <server.worlds> as:world:
      - foreach <[world].entities> as:entity:
        - flag server entity_counts.<[entity].location.chunk>:+:1
    - foreach <server.flag[entity_counts]> key:key as:value:
      - if <[value]> > 10:
        - narrate "<[key]> - <[value]>"
    - flag server entity_counts:!