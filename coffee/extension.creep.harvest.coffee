Creep::aiHarvest = ->
  harvestTarget = Game.getObjectById(@memory.harvestTarget ? '')
  unless harvestTarget and @room.lookForAt(LOOK_SOURCES, harvestTarget)
    harvestTarget = @aiGetAndStoreTarget FIND_SOURCES, 'harvestTarget'
  return unless harvestTarget?
  if @harvest(harvestTarget) is ERR_NOT_IN_RANGE
    @moveTo harvestTarget