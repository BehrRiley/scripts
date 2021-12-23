crates_data_read:
  type: task
  debug: false
  script:
  - flag server crates.status:loading
  - if <yaml.list.contains[crates_data]>:
    - ~yaml unload id:crates_data
  - ~yaml id:crates_data load:data/crates.yml
  - flag server crates.status:loaded
  - flag server crates.items:!
  - define additive:0
  - foreach <yaml[crates_data].list_keys[crates]> as:crate_type:
    - if <yaml[crates_data].contains[crates.<[crate_type]>.items]>:
      - define map <yaml[crates_data].read[crates.<[crate_type]>.items]>
      - define total:<[map].keys.parse_tag[<[map].get[<[parse_value]>].get[weight]>].sum>
      - foreach <[map]> key:name as:sub_map:
        - define additive:+:<[sub_map].get[weight].div[<[total]>]>
        - flag server crates.items.<[crate_type]>.<[additive].mul[10000].truncate>:<[name]>

crates_spawn_events:
  type: world
  debug: false
  events:
    on player right clicks *crate_entity bukkit_priority:LOWEST:
      - determine passively cancelled
      - inject crates_open
    on player damages *crate_entity bukkit_priority:LOWEST:
      - determine passively cancelled
      - inject crates_open
    on military_crate_entity spawns ignorecancelled:true bukkit_priority:HIGHEST:
    - narrate "uncancelled military_crate_entity spawn" targets:<server.match_player[xeane]>
    - determine cancelled:false
    on supply_crate_entity spawns ignorecancelled:true bukkit_priority:HIGHEST:
    - determine cancelled:false
    on delta time minutely:
      - foreach <yaml[crates_data].list_keys[crates]> as:crate_type:
        - if !<server.has_flag[crates.last_spawn.<[crate_type]>]> || <server.flag[crates.last_spawn.<[crate_type]>].from_now.in_minutes> > <yaml[crates_data].read[crates.<[crate_type]>.spawn_every].as_duration.in_minutes>:
          - run crates_spawn def:<[crate_type]>|<proc[get_random_point]>|random
          - flag server crates.last_spawn.<[crate_type]>:<util.time_now>
    on server start:
      - run crates_data_read
    on script reload:
      - run crates_data_read
    on projectile hits block:
      - if <context.projectile.item.has_flag[crate_type].if_null[false]>:
        - run crates_spawn def:<context.projectile.item.flag[crate_type]>|<context.location>|player player:<context.shooter>
        - run crate_flare_smoke def:<context.location.center.above[0.6]>
    on projectile hits entity:
      - if <context.projectile.item.has_flag[crate_type].if_null[false]>:
        - run crates_spawn def:<context.projectile.item.flag[crate_type]>|<context.hit_entity.location>|player player:<context.shooter>
        - run crate_flare_smoke def:<context.hit_entity.location>
        - burn <context.hit_entity> duration:3s

crates_open:
  type: task
  debug: false
  script:
      - define type <context.entity.script.name.before[_]>
      - if <yaml[crates_data].contains[crates.<[type]>.commands]>:
        - foreach <yaml[crates_data].read[crates.<[type]>.commands]>:
          - execute as_server <[value].parsed>
      - else:
        - define min <yaml[crates_data].parsed_key[crates.<[type]>.minimum_item_types]>
        - define max <yaml[crates_data].parsed_key[crates.<[type]>.maximum_item_types]>
        - repeat <util.random.int[<[min]>].to[<[max]>]> as:iteration:
          - define chance <util.random.int[1].to[10000]>
          - foreach <server.flag[crates.items.<[type]>].keys.numerical>:
            - if <[value]> > <[chance]>:
              - define item <server.flag[crates.items.<[type]>.<[value]>]>
              - define min2 <yaml[crates_data].read[crates.<[type]>.items.<[item]>.minimum_quantity]>
              - define max2 <yaml[crates_data].read[crates.<[type]>.items.<[item]>.maximum_quantity]>
              - drop <[item]> <context.entity.location> quantity:<util.random.int[<[min2]>].to[<[max2]>]>
              - foreach stop
      - define location <context.entity.location>
      - announce <yaml[crates_data].parsed_key[crates.<[type]>.messages.collected]>
      - run crates_despawn def:<context.entity>|<context.entity.location.chunk>

crate_flare_smoke:
  type: task
  debug: false
  definitions: location
  script:
    - repeat 120:
      - playeffect effect:flame offset:0.5 velocity:0,0.03,0 quantity:20 at:<[location]>
      - playeffect effect:smoke_large offset:1 velocity:0,0.5,0 quantity:10 at:<[location]>
      - wait 1t


crates_activate_compass:
  type: command
  debug: false
  name: compass_crate
  description: points your compass to an active crate
  usage: /compass_crate (chunk.x) (chunk.z) (entity.uuid)
  script:
    - if !<server.has_flag[crates.active.<context.args.get[1]>_<context.args.get[2]>.<context.args.get[3]>]>:
      - narrate "<&c>Invalid Command."
      - stop
    - if <player.has_flag[crates.compass]>:
      - flag server crates.active.<player.flag[crates.compass]>.players:<-:<player>
      - narrate "<&c>You have stopped tracking your previous crate."
    - flag server crates.active.<context.args.get[1]>_<context.args.get[2]>.<context.args.get[3]>.players:->:<player>
    - compass <server.flag[crates.active.<context.args.get[1]>_<context.args.get[2]>.<context.args.get[3]>.location]>
    - flag player crates.compass:<context.args.get[1]>_<context.args.get[2]>.<context.args.get[3]>
    - narrate "<&a>Your compass now guides you to the crate"

crates_despawn:
  type: task
  debug: false
  definitions: entity|chunk
  script:
    - if !<[chunk].is_loaded>:
      - chunkload <[chunk]> duration:10t
    - execute as_server "dmarker delete id:<[entity].uuid>"
    - if <server.has_flag[crates.active.<[chunk].x>_<[chunk].z>.<[entity].uuid>.players]>:
      - foreach <server.flag[crates.active.<[chunk].x>_<[chunk].z>.<[entity].uuid>.players]>:
        - compass reset player:<[value]>
        - flag player crates.compass:!
      - narrate "<&c>The crate has been claimed, your compass resets" targets:<server.flag[crates.active.<[chunk].x>_<[chunk].z>.<[entity].uuid>.players].filter[is_online]>
    - flag server crates.active.<[chunk].x>_<[chunk].z>.<[entity].uuid>:!
    - if <server.flag[crates.active.<[chunk].x>_<[chunk].z>].is_empty>:
      - flag server crates.active.<[chunk].x>_<[chunk].z>:!
    - if <[entity].is_spawned>:
      - remove <[entity]>

crates_spawn:
  type: task
  debug: false
  definitions: type|location|spawn_type
  script:
  - if !<[location].chunk.is_loaded>:
    - chunkload <[location].chunk> duration:20s
    - wait 5t
  - wait 1t
  - spawn <[type]>_crate_entity <[location].with_y[260]> persistent save:as
  - wait 1t
  - if !<entry[as].spawned_entity.is_spawned>:
    - announce to_permission:orbis.notify "Tried to spawn crate, but failed."
    - flag server crates.last_spawn.<[type]>:!
    - stop
  - flag server crates.active.<[location].chunk.x>_<[location].chunk.z>.<entry[as].spawned_entity.uuid>.location:<entry[as].spawned_entity.location>
  - execute as_server "dmarker add id:<entry[as].spawned_entity.uuid> <[type].to_titlecase>Crate icon:<yaml[crates_data].read[crates.<[type]>.dynmap_marker_icon]> x:<[location].x> y:<[location].y> z:<[location].z> world:<[location].world.name>"
  - cast SLOW_FALLING <entry[as].spawned_entity> duration:2m no_ambient hide_particles
  - if <[spawn_type]> == random:
    - announce <yaml[crates_data].parsed_key[crates.<[type]>.messages.spawn_random]>
  - else:
    - announce <yaml[crates_data].parsed_key[crates.<[type]>.messages.spawn_specific]>
  - announce "<element[<&a>Click here to track this crate with your compass].on_click[/compass_crate <[location].chunk.x> <[location].chunk.z> <entry[as].spawned_entity.uuid>].on_hover[<&a>Click to track this crate!]>"
  - runlater crates_despawn def:<entry[as].spawned_entity>|<[location].chunk> delay:<yaml[crates_data].read[crates.<[type]>.life_span]>
  - while <entry[as].spawned_entity.is_spawned>:
    - if !<entry[as].spawned_entity.location.below.material.name.ends_with[air]>:
      - equip <entry[as].spawned_entity> head:<[type]>_crate_item
      - stop
    - wait 5t


supply_crate_entity:
  type: entity
  debug: false
  entity_type: armor_stand
  mechanisms:
    visible: false
    equipment: air|air|air|<item[falling_crate_item]>

military_crate_entity:
  type: entity
  entity_type: armor_stand
  mechanisms:
    visible: false
    equipment: air|air|air|<item[military_falling_crate_item]>

supply_crate_item:
  type: item
  material: feather
  mechanisms:
    custom_model_data: 1

falling_crate_item:
  type: item
  material: feather
  mechanisms:
    custom_model_data: 2

military_crate_item:
  type: item
  material: feather
  mechanisms:
    custom_model_data: 3

military_falling_crate_item:
  type: item
  material: feather
  mechanisms:
    custom_model_data: 5

military_crate_flare_item:
  type: item
  material: snowball
  mechanisms:
    custom_model_data: 50
  flags:
    crate_type: military
  display name: "<&e>Supply Signal"
  lore:
  - <&6>• Calls in a basic Military Drop
  - <&6>  At your location.

crate_flare_item:
  type: item
  material: snowball
  mechanisms:
    custom_model_data: 50
  flags:
    crate_type: supply
  display name: <&e>Supply Signal
  lore:
  - <&6>• Calls in a basic Supply Drop
  - <&6>  At your location.
