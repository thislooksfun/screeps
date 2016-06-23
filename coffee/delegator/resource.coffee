module.exports =
  
  loadResources: ->
    Memory.delegators ?= {}
    Memory.delegators.resources ?= {}
    for name, room of Game.rooms
      continue if Memory.delegators.resources[name]? #TODO: Renable to only check new rooms
      @loadResourcesForRoom room
      break #Only process one room / tick
    return #Block auto-return
  
  
  loadResourcesForRoom: (room) ->
    paths = {}
    
    sources = room.find FIND_SOURCES
    
    for source in sources
      paths["#{source.pos.x},#{source.pos.y}"] = @calculateValidPathsForSource source, room
    
    Memory.delegators.resources[room.name] = paths
    return #Block auto-return
  
  calculateValidPathsForSource: (source, room) ->
    sourceX = source.pos.x
    sourceY = source.pos.y
    
    paths = 0
    
    for transform in transforms
      if isTileWalkable room, sourceX + transform.x, sourceY + transform.y
        paths |= transform.path
    
    return paths

PATH =
  UP_LEFT: 1<<0
  UP: 1<<1
  UP_RIGHT: 1<<2
  LEFT: 1<<3
  RIGHT: 1<<4
  DOWN_LEFT: 1<<5
  DOWN: 1<<6
  DOWN_RIGHT: 1<<7

transforms = [
  {x: -1, y: -1, path: PATH.UP_LEFT},
  {x: 0, y: -1, path: PATH.UP},
  {x: 1, y: -1, path: PATH.UP_RIGHT},
  {x: -1, y: 0, path: PATH.LEFT},
  {x: 1, y: 0, path: PATH.RIGHT},
  {x: -1, y: 1, path: PATH.DOWN_LEFT},
  {x: 0, y: 1, path: PATH.DOWN},
  {x: 1, y: 1, path: PATH.DOWN_RIGHT},
]

isTileWalkable = (room, x, y) ->
  items = room.lookAt(x, y)
  obstructed = false
  for item, i in items
    continue if item.type is LOOK_CREEPS
    if OBSTACLE_OBJECT_TYPES.includes(item.type) or OBSTACLE_OBJECT_TYPES.includes item[item.type]
      obstructed = true
      break
  return not obstructed