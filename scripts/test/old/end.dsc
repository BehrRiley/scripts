end_events:
	type: world
    debug: false
    events:
      after player changes world to world_the_end:
        - inject get_random_point_task
        - teleport <[loc]> <player>