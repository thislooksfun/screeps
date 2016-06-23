Creep::aiTransfer = (type, isValidStorageStructure) ->
  energy_containers = @room.find FIND_STRUCTURES, {filter: isValidStorageStructure}
  if energy_containers.length > 0
    if @transfer(energy_containers[0], RESOURCE_ENERGY) is ERR_NOT_IN_RANGE
      @moveTo energy_containers[0]
    return true
  
  return false

Creep::aiTransferEnergy = ->
  return @aiTransfer RESOURCE_ENERGY, (structure) -> return structure.canStoreMoreEnergy()