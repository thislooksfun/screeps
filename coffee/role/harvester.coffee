module.exports =
  
  body: ->
    return [WORK, CARRY, MOVE]
  
  countPerRoom: 2
  
  ### @param {Creep} creep ###
  run: (creep) ->
    # creep.say "#{creep.carry.energy}/#{creep.carryCapacity}"
    if creep.carry.energy < creep.carryCapacity
      creep.aiHarvest()
    else
      creep.aiDoneHarvesting()
      unless creep.aiTransferEnergy()
        creep.aiBuild()
    return #Block auto-return