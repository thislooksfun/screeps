Creep::aiBuild = ->
  buildTarget = Game.getObjectById(@memory.buildTarget ? '')
  unless buildTarget and @room.lookForAt(LOOK_CONSTRUCTION_SITES, buildTarget)
    buildTarget = @aiGetAndStoreTarget FIND_CONSTRUCTION_SITES, 'buildTarget'
  
  return false unless buildTarget?
  
  if @build(buildTarget) is ERR_NOT_IN_RANGE
    @moveTo buildTarget
  return true