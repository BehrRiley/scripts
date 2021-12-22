portal_log:
  type: world
  debug: false
  events:
    on player teleports:
      - if <context.cause> == END_PORTAL:
        - determine passively cancelled
        - ~log <context.origin.block> file:end_entryways.txt
        - inject get_random_point_task
        - wait 1t
        - teleport <player> <[loc]>