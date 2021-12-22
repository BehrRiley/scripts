custom_big_dripleaf:
    type: item
    material: big_dripleaf
    no_id: true
    recipes:
        1:
            type: shaped
            recipe_id: big_dripleaf1
            output_quantity: 1
            input:
            - moss_block|moss_block|lily_pad
            - moss_block|moss_block|air
            - air|air|air

custom_azalea:
    type: item
    material: azalea
    no_id: true
    recipes:
        1:
            type: shaped
            recipe_id: azalea1
            output_quantity: 1
            input:
            - moss_block|moss_block|moss_block
            - moss_block|spruce_sapling|moss_block
            - moss_block|moss_block|moss_block
            
custom_flowering_azalea:
    type: item
    material: flowering_azalea
    no_id: true
    recipes:
        1:
            type: shaped
            recipe_id: flowering_azalea1
            output_quantity: 1
            input:
            - air|pink_tulip|air
            - pink_tulip|azalea|pink_tulip
            - air|pink_tulip|air
            
custom_sporeblossom:
    type: item
    material: spore_blossom
    no_id: true
    recipes:
        1:
            type: shaped
            recipe_id: spore_blossom1
            output_quantity: 1
            input:
            - moss_block|pink_tulip|moss_block
            - moss_block|air|air
            - air|air|air
            
custom_moss_block:
    type: item
    material: moss_block
    no_id: true
    recipes:
        1:
            type: shaped
            recipe_id: moss_block1
            output_quantity: 1
            input:
            - grass_block|grass_block|air
            - grass_block|grass_block|air
            - air|air|air
            
custom_small_dripleaf:
    type: item
    material: small_dripleaf
    no_id: true
    recipes:
        1:
            type: shaped
            recipe_id: small_dripleaf1
            output_quantity: 1
            input:
            - grass_block|lily_pad|air
            - air|air|air
            - air|air|air
            
custom_bell:
    type: item
    material: bell
    no_id: true
    recipes:
        1:
            type: shaped
            recipe_id: bell1
            output_quantity: 1
            input:
            - stone|stick|stone
            - stone|golden_block|stone
            - stone|air|stone
            
custom_ink_sac:
    type: item
    material: ink_sac
    no_id: true
    recipes:
        1:
            type: shaped
            recipe_id: ink_sac1
            output_quantity: 2
            input:
            - coal|charcoal|air
            - charcoal|coal|air
            - air|air|air
            
custom_string:
    type: item
    material: string
    no_id: true
    recipes:
        1:
            type: shapeless
            recipe_id: string1
            output_quantity: 4
            input: *wool