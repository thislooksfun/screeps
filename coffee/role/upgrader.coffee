module.exports =
  
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
  
  countPerRoom: 2
  
  ### @param {Creep} creep ###
  run: (creep) ->
    if creep.memory.isUpgrading and creep.carry.energy is 0
      creep.memory.isUpgrading = false
    if not creep.memory.isUpgrading and creep.carry.energy is creep.carryCapacity
      creep.memory.isUpgrading = true
    
    if creep.memory.isUpgrading
      creep.aiDoneHarvesting()
      creep.aiUpgrade()
    else
      creep.aiHarvest()
    return #Block auto-return