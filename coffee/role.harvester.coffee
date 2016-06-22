module.exports =
  
  body: [WORK, CARRY, MOVE]
  
  countPerRoom: 1
  
  ### @param {Creep} creep ###
  run: (creep) ->
    # creep.say "#{creep.carry.energy}/#{creep.carryCapacity}"
    if creep.carry.energy < creep.carryCapacity
      sources = creep.room.find FIND_SOURCES
      source = sources[0] #TODO: Pick via algorithm
      if creep.harvest(source) is ERR_NOT_IN_RANGE
        creep.moveTo source
    else
      energy_containers = creep.room.find FIND_STRUCTURES, {filter: isValidStorageStructure}
      if energy_containers.length > 0
        if creep.transfer(energy_containers[0], RESOURCE_ENERGY) is ERR_NOT_IN_RANGE
          creep.moveTo energy_containers[0]
      else
        build_sites = creep.room.find FIND_CONSTRUCTION_SITES
        if build_sites.length > 0 and creep.build(build_sites[0]) is ERR_NOT_IN_RANGE
          creep.moveTo build_sites[0]
    return #Block auto-return


isValidStorageStructure = (structure) ->
  validBuildingType = switch structure.structureType
    when STRUCTURE_SPAWN, STRUCTURE_EXTENSION
       , STRUCTURE_CONTAINER, STRUCTURE_STORAGE
      true
    else
      false
  
  return validBuildingType and structure.energy < structure.energyCapacity