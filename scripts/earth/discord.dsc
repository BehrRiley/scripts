discord_startup:
	type: world
    debug: false
    config:
    	defaults:
        	discord:
            	message_format: "<player.name> : <context.message>"
    events:
    	on server starts:
        - stop
        - ~discordconnect id:orbis tokenfile:data/discord.txt
        on player chats:
        - stop
        - ~discordmessage id:orbis channel:<discord[orbis].group[Orbis].channel[in-game-chat]> <yaml[config].read[discord.message_format].parsed>