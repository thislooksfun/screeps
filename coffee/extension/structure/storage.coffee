Structure::canStoreMoreEnergy = ->
  type = @structureType
  
  if type is STRUCTURE_SPAWN or type is STRUCTURE_EXTENSION
    return @energy < @energyCapacity
  else if type is STRUCTURE_CONTAINER or type is STRUCTURE_STORAGE
    return _.sum(@.store) < @storeCapacity
  
  return false