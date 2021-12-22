command_test:
	type: command
    debug: false
    name: test
    script:
    - if <player.has_permission[testcommand].not>:
    	- stop
    - define player1 <server.match_player[<context.args.get[1]>]>
    - define player2 <server.match_player[<context.args.get[2]>]>
    - run start_fight def:<[player1]>|<[player2]>|test