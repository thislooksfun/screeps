StructureTower::aiTick = ->
  return true if @aiAttack()
  return true if @aiHeal()
  return true if @aiRepair()
  return false

StructureTower::aiAttack = ->
  hostiles = @room.find FIND_HOSTILE_CREEPS
  return false unless hostiles.length > 0
  @attack hostiles[0]
  return true

StructureTower::aiHeal = ->
  lowHealth = (creep) -> return creep.hits < creep.hitsMax
  lowHealthCreeps = @room.find FIND_MY_CREEPS, {filter: lowHealth}
  return false unless lowHealthCreeps.length > 0
  lowHealthCreeps.sort (a, b) -> return a.hits - b.hits
  @heal lowHealthCreeps[0]
  return true

StructureTower::aiRepair = ->
  lowHealth = (struct) ->
    return false if struct.structureType is STRUCTURE_ROAD
    return false if struct.hits > 10000
    return struct.hits < struct.hitsMax
  lowHealthStructs = @room.find FIND_STRUCTURES, {filter: lowHealth}
  return false unless lowHealthStructs.length > 0
  lowHealthStructs.sort (a, b) -> return a.hits - b.hits
  @repair lowHealthStructs[0]
  return true