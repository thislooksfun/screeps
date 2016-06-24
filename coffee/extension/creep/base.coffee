Creep::aiGetAndStoreTarget = (find, name) ->
  sources = @room.find find
  if sources.length > 0
    @memory[name] = sources[0].id
    return sources[0]
  return null

Creep::distanceTo = (pos) ->
  return Math.max(Math.abs(@pos.x - pos.x), Math.abs(@pos.y - pos.y))

Creep::partCount = (type) ->
  parts = _.filter @body, (part) -> return part.type is type
  return parts.length