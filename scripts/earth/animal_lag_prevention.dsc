animal_lag_prevention:
  type: world
  debug: false
  data:
    types:
    - sheep
    - rabbit
    - cow
    - pig
  events:
    on delta time minutely every:10:
      - foreach <script.data_key[data.types]> as:animal_type:
        - remove <world[world].entities[<[animal_type]>].filter[location.has_town.not]>
        - wait 1s