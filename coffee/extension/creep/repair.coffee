Creep::aiRepair = (healthFilter) ->
  targets = @room.find FIND_STRUCTURES, {filter: healthFilter}
  
  return false unless targets.length > 0
  
  targets.sort (a, b) =>
    diff = a.hits - b.hits
    return diff unless diff is 0
    return @distanceTo(a.pos) - @distanceTo(b.pos)
  
  if @repair(targets[0]) is ERR_NOT_IN_RANGE
    @moveTo targets[0]
  return true

Creep::aiRepairPercent = (percent) ->
  return @aiRepair (structure) -> return structure.hits < (structure.hitsMax * (percent / 100))

Creep::aiRepairLeveledAmount = (healthPerWork) ->
  return @aiRepair (struct) =>
    return struct.hits < (healthPerWork * @partCount(WORK)) and struct.hits < struct.hitsMax

Creep::aiRepairPriorityUrgent = -> return @aiRepairLeveledAmount 500
Creep::aiRepairPriorityHigh = -> return @aiRepairLeveledAmount 2500
Creep::aiRepairPriorityMedium = -> return @aiRepairPercent 25
Creep::aiRepairPriorityLow = -> return @aiRepairPercent 50
Creep::aiRepairPriorityMinimal = -> return @aiRepairPercent 75

Creep::aiRepairAll = ->
  return @aiRepair (structure) ->
    return structure.hits < structure.hitsMax