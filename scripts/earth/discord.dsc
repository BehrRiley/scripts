discord_startup:
    type: world
    debug: false
    config:
        defaults:
            discord:
                message_format: "<player.name> : <context.message>"
    events:
        after server start:
        - stop
        - ~discordconnect id:orbis tokenfile:data/discord.txt
        on player chats:
        - stop
        - ~discordmessage id:orbis channel:<discord[orbis].group[Orbis].channel[in-game-chat]> <yaml[config].parsed_key[discord.message_format]>
