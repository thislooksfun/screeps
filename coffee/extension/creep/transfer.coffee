Creep::aiTransfer = (type, isValidStorageStructure, sortStorage) ->
  energy_containers = @room.find FIND_STRUCTURES, {filter: isValidStorageStructure}
  
  if sortStorage?
    energy_containers.sort sortStorage
  
  if energy_containers.length > 0
    if @transfer(energy_containers[0], RESOURCE_ENERGY) is ERR_NOT_IN_RANGE
      @moveTo energy_containers[0]
    return true
  
  return false


# hightest # = hightest priority
energyContainerPreference =
  "#{STRUCTURE_SPAWN}": 4
  "#{STRUCTURE_EXTENSION}": 3
  "#{STRUCTURE_TOWER}": 2
  "#{STRUCTURE_CONTAINER}": 1
  "#{STRUCTURE_STORAGE}": 1

Creep::aiTransferEnergy = ->
  filter = (structure) -> return structure.canStoreMoreEnergy()
  sort = (a, b) ->
    apref = energyContainerPreference[a.structureType] or 0
    bpref = energyContainerPreference[b.structureType] or 0
    return bpref - apref
  return @aiTransfer RESOURCE_ENERGY, filter, sort