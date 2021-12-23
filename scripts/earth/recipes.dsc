
custom_item_recipe_gunpowder:
    type: item
    material: gunpowder
    no_id: true
    recipes:
        1:
            type: shaped
            recipe_id: custom_item_recipe_gunpowder1
            output_quantity: 2
            input:
            - gravel|raw_copper|gravel
            - raw_copper|gravel|raw_copper
            - gravel|raw_copper|gravel
        2:
            type: shaped
            recipe_id: custom_item_recipe_gunpowder2
            output_quantity: 2
            input:
            - gravel|copper_ingot|gravel
            - copper_ingot|gravel|copper_ingot
            - gravel|copper_ingot|gravel

ammunition_rocket:
    type: item
    material: ghast_tear
    display name: §g§6RPG-7 Rocket
    mechanisms:
        custom_model_data: 510
    recipes:
        1:
            type: shaped
            recipes_id: custom_item_recipe_rocket2
            output_quantity: 1
            input:
            - air|copper_block|air
            - iron_block|fire_charge|iron_block
            - iron_block|material:firework_rocket|iron_block

ammunition_magazine:
    type: item
    material: ghast_tear
    display name: §g§6Magazine
    mechanisms:
        custom_model_data: 1
    recipes:
        1:
            type: shapeless
            recipes_id: custom_item_recipe_magazine1
            output_quantity: 1
            input: gunpowder|copper_ingot|copper_ingot

ammunition_shotgun_shell:
    type: item
    material: ghast_tear
    display name: §g§6ShotGun Shell
    mechanisms:
        custom_model_data: 3
    recipes:
        1:
            type: shapeless
            recipes_id: custom_item_recipe_shotgun_shell1
            output_quantity: 6
            input: gunpowder|copper_ingot|gold_ingot

ammunition_clip:
    type: item
    material: ghast_tear
    display name: §g§6Clip
    mechanisms:
        custom_model_data: 2
    recipes:
        1:
            type: shapeless
            recipes_id: custom_item_recipe_clip1
            output_quantity: 1
            input: gunpowder|copper_ingot
