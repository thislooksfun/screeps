resourceDelegator = require 'delegator.resource'

Creep::aiHarvest = ->
  source = Game.getObjectById(@memory.harvestTarget?.sourceID ? '')
  unless source and @room.lookForAt(LOOK_SOURCES, source)
    output = resourceDelegator.getFreeSourceHarvestLocationInRoom @room
    @memory.harvestTarget = output
    return false unless @memory.harvestTarget?
    source = Game.getObjectById(@memory.harvestTarget?.sourceID ? '')
  
  return false unless source?
  
  if @harvest(source) is ERR_NOT_IN_RANGE
    @moveTo @memory.harvestTarget.pos.x, @memory.harvestTarget.pos.y
  return true

Creep::aiDoneHarvesting = ->
  return true unless @memory.harvestTarget?
  resourceDelegator.stoppedHarvestingAt @memory.harvestTarget
  delete @memory.harvestTarget