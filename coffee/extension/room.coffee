Room::findHostiles = ->
  return @find(FIND_HOSTILE_CREEPS).concat(
    @find(FIND_HOSTILE_STRUCTURES),
    @find(FIND_HOSTILE_CONSTRUCTION_SITE)
  )