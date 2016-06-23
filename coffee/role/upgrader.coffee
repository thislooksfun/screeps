module.exports =
  
  body: [WORK, CARRY, MOVE]
  
  countPerRoom: 2
  
  ### @param {Creep} creep ###
  run: (creep) ->
    if creep.memory.isUpgrading and creep.carry.energy is 0
      creep.memory.isUpgrading = false
    if not creep.memory.isUpgrading and creep.carry.energy is creep.carryCapacity
      creep.memory.isUpgrading = true
    
    if creep.memory.isUpgrading
      creep.aiUpgrade()
    else
      creep.aiHarvest()
    return #Block auto-return