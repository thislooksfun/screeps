module.exports =
  countPerRoom: 4
  
  body: ->
    #TODO: make dynamic
    return [WORK, CARRY, MOVE]
  
  run: (creep) ->
    if creep.memory.isWorking and creep.carry.energy is 0
      creep.memory.isWorking = false
    if not creep.memory.isWorking and creep.carry.energy is creep.carryCapacity
      creep.aiDoneHarvesting()
      creep.memory.isWorking = true
    
    if creep.memory.isWorking
      return if creep.aiTransferEnergy()
      return if creep.aiBuild()
    else
      creep.aiHarvest()
    return #Block auto-return