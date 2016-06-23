module.exports =
  
  body: [WORK, CARRY, MOVE]
  
  countPerRoom: 3
  
  ### @param {Creep} creep ###
  run: (creep) ->
    # creep.say "#{creep.carry.energy}/#{creep.carryCapacity}"
    if creep.carry.energy < creep.carryCapacity
      creep.aiHarvest()
    else
      unless creep.aiTransferEnergy()
        creep.aiBuild()
    return #Block auto-return