bookshelves_events:
  type: world
  debug: false
  events:
    on player clicks bookshelf:
      - if <context.cancelled>:
        - stop
      - if <context.click_type.starts_with[RIGHT]> && !<player.is_sneaking>:
        - if <inventory[bookshelf_<context.location.simple>]||null> == null:
          - note <inventory[bookshelves_inventory]> as:bookshelf_<context.location.simple>
       # - if <proc[check_perms_l2].context[<player>|<context.location>]>:
       #   - determine passively cancelled
        - inventory open d:<inventory[bookshelf_<context.location.simple>]>
        - determine passively cancelled
    on player breaks bookshelf:
      - if <context.cancelled>:
        - stop
      - if <inventory[bookshelf_<context.location.simple>]||null> != null:
        - foreach <inventory[bookshelf_<context.location.simple>].list_contents> as:item:
          - drop <[item]> <context.location>
        - note remove as:bookshelf_<context.location.simple>
    on piston extends:
      - foreach <context.blocks> as:block:
        - if <inventory[bookshelf_<[block].simple>]||null> != null:
          - determine passively cancelled
    on piston retracts:
      - foreach <context.blocks> as:block:
        - if <inventory[bookshelf_<[block].simple>]||null> != null:
          - determine passively cancelled
    on player drags in bookshelves_inventory:
      - if <context.raw_slots.filter[is_greater_than[9]].size> > 0:
        - stop
      - if !<list[book|writable_book|written_book|enchanted_book|air].contains[<context.cursor_item.material.name.to_lowercase||>]>:
        - determine passively cancelled
    on player clicks in bookshelves_inventory:
      - if <context.raw_slot> > 9:
        - stop
      - if <context.hotbar_button> != 0 && !<list[book|writable_book|written_book|enchanted_book|air].contains[<player.inventory.slot[<context.hotbar_button>].material.name.to_lowercase>]>:
        - determine passively cancelled
      - if !<list[book|writable_book|written_book|enchanted_book|air].contains[<context.cursor_item.material.name.to_lowercase>]>:
        - determine passively cancelled

bookshelves_inventory:
  type: inventory
  inventory: chest
  title: Bookshelf
  size: 9
  slots:
  - [] [] [] [] [] [] [] [] []
