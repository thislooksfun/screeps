Creep::aiGetAndStoreTarget = (find, name) ->
  sources = @room.find find
  if sources.length > 0
    @memory[name] = sources[0].id
    return sources[0]
  return null