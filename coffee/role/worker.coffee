module.exports =
  countPerRoom: 4
  
  bodyForRoom: (room) ->
    maxEnergy = room.energyCapacityAvailable
    partsMove = Math.floor maxEnergy / 50 / 5
    partsCarry = partsMove
    energyUsed = partsMove * 50
    energyUsed += partsCarry * 50
    partsWork = Math.floor (maxEnergy - energyUsed) / 100
    body = []
    
    for i in [0...partsMove]
      body.push MOVE
    for i in [0...partsCarry]
      body.push CARRY
    for i in [0...partsWork]
      body.push WORK
    return body
  
  run: (creep) ->
    if creep.memory.isWorking and creep.carry.energy is 0
      creep.memory.isWorking = false
    if not creep.memory.isWorking and creep.carry.energy is creep.carryCapacity
      creep.aiDoneHarvesting()
      creep.memory.isWorking = true
    
    if creep.memory.isWorking
      # TODO: Add upgrading in here?
      # TODO: Add task delegation? (x ticks and/or x creeps per task?)
      return if creep.aiRepairUrgent()
      return if creep.aiTransferEnergy()
      return if creep.aiBuild()
      return if creep.aiRepairHigh()
      return if creep.aiRepairMedium()
      return if creep.aiRepairLow()
      return if creep.aiRepairMinimal()
      return if creep.aiRepairAll()
    else
      creep.aiHarvest()
    return #Block auto-return