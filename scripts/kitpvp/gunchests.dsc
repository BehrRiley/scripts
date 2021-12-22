gunchest_handler:
	type: world
    debug: false
    events:
    	on server start:
        - yaml id:skins load:../CrackShotPlus/skins/Default_Weapon_Skins.yml
    	on player right clicks block:
        - if <player.name> != AJ_4real:
        	- stop
        - if !<context.location.note_name.starts_with[gunchest]||false> && !<context.location.other_block.note_name.starts_with[gunchest]||false>:
        	- stop
        - define loc <context.location>
        - if <context.location.other_block||null> != null:
        	- define loc <context.location.center.add[<context.location.other_block.center>].div[2]>
        - define loc <[loc].face[<[loc].add[<[loc].block_facing>]>]>
        - define loc <[loc].below[1].with_yaw[<[loc].yaw.add[90]>]>
        - animatechest <context.location>
        - spawn gunchest_entity <[loc]> save:entity
        - define entity <entry[entity].spawned_entity>
        - wait 1t
        - repeat 10:
        	- define gun <yaml[skins].list_keys[].random.replace[_NoSkin].with[]>
            - if <[entity]||null> == null:
            	- stop
        	- adjust <[entity]> equipment:air|air|air|<crackshot.weapon[<[gun]>].with[custom_model_data=<yaml[skins].read[<[gun]>_NoSkin.Custom_Model_Data]||0>]>
            - wait 10t
		- remove <[entity]>


gunchest_entity:
	type: entity
    entity_type: armor_stand
    gravity: false
    visible: false