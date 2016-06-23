module.exports =
  
  body: ->
    return [WORK, CARRY, MOVE]
  
  countPerRoom: 4
  
  ### @param {Creep} creep ###
  run: (creep) ->
    if creep.memory.isBuilding and creep.carry.energy is 0
      creep.memory.isBuilding = false
    if not creep.memory.isBuilding and creep.carry.energy is creep.carryCapacity
      creep.memory.isBuilding = true
    
    if creep.memory.isBuilding
      creep.aiDoneHarvesting()
      creep.aiBuild()
    else
      creep.aiHarvest()
    return #Block auto-return