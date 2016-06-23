Creep::aiUpgrade = ->
  if @upgradeController(@room.controller) is ERR_NOT_IN_RANGE
    @moveTo @room.controller
  return true