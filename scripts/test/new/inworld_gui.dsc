inworld_gui_armorstand:
  type: entity
  entity_type: armor_stand
  mechanisms:
    custom_name: <&b>Placeholder
    custom_name_visible: false
    equipment:
    - air
    - air
    - air
    - feather[custom_model_data=6]
    visible: false
  flags:
    right_click_script: narrate_stuff

inworld_gui_menu_spawn:
  type: task
  debug: false
  script:
    - define loc <player.location.with_pitch[0]>
    - if <[loc].left.to_cuboid[<[loc].forward[2].right>].blocks[!air].filter[is_solid].size> > 0:
      - narrate nope
      - stop
    - fakespawn inworld_gui_armorstand[flag=custom_name=<&d>Enderchest] <[loc].forward[2].below[0.75]> duration:10s save:as1
    - flag <entry[as1].faked_entity> right_click_script:ender_chest_open
    - fakespawn inworld_gui_armorstand <[loc].forward[2].above[0.75]> duration:10s
    - fakespawn inworld_gui_armorstand <[loc].forward[2].left.below[0.75]> duration:10s
    - fakespawn inworld_gui_armorstand <[loc].forward[2].left.above[0.75]> duration:10s
    - fakespawn inworld_gui_armorstand <[loc].forward[2].right.below[0.75]> duration:10s
    - fakespawn inworld_gui_armorstand <[loc].forward[2].right.above[0.75]> duration:10s

inworld_gui_menu_events:
  type: world
  debug: true
  events:
    on player clicks fake entity:
      - if <context.entity.has_flag[right_click_script]>:
        - inject <context.entity.flag[right_click_script]>

ender_chest_open:
  type: task
  debug: false
  script:
  - inventory open d:<player.enderchest>

narrate_stuff:
  type: task
  debug: false
  script:
  - narrate STUFF!
