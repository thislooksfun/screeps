###
thislooksfun's personal Screeps scripts
Copyright (C) 2016  thislooksfun

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

module.exports =
  
  loadResources: ->
    Memory.delegators ?= {}
    Memory.delegators.resources ?= {}
    for name, room of Game.rooms
      continue if Memory.delegators.resources[name]? #TODO: Renable to only check new rooms
      @loadResourcesForRoom room
      break #Only process one room / tick
    return #Block auto-return
  
  
  getFreeSourceHarvestLocationInRoom: (room, flagName) ->
    resources = Memory.delegators?.resources?[room.name]
    unless resources?
      @loadResources()
      resources = Memory.delegators?.resources?[room.name]
      return null unless resources?  #If they don't exist by this point, there's nothing I can do
    for posStr, data of resources
      continue unless data.freeTiles
      pos = posStr.split ','
      x = parseInt pos[0]
      y = parseInt pos[1]
      path = 0
      if data.freeTiles & PATH.UP_LEFT
        path = PATH.UP_LEFT
        x -= 1
        y -= 1
      else if data.freeTiles & PATH.UP
        path = PATH.UP
        # x += 0
        y -= 1
      else if data.freeTiles & PATH.UP_RIGHT
        path = PATH.UP_RIGHT
        x += 1
        y -= 1
      else if data.freeTiles & PATH.LEFT
        path = PATH.LEFT
        x -= 1
        # y += 0
      else if data.freeTiles & PATH.RIGHT
        path = PATH.RIGHT
        x += 1
        # y += 0
      else if data.freeTiles & PATH.DOWN_LEFT
        path = PATH.DOWN_LEFT
        x -= 1
        y += 1
      else if data.freeTiles & PATH.DOWN
        path = PATH.DOWN
        # x += 0
        y += 1
      else if data.freeTiles & PATH.DOWN_RIGHT
        path = PATH.DOWN_RIGHT
        x += 1
        y += 1
      
      data.freeTiles &= ~path
      flags = room.lookForAt LOOK_FLAGS, x, y
      flag.remove() for flag in flags
      if flagName?
        room.createFlag(x, y, flagName, COLOR_YELLOW)
      return {sourceID: data.sourceID, pos: new RoomPosition(x, y, room.name), path: path}
    return null
  
  
  stoppedHarvestingAt: ({pos, path}) ->
    resources = Memory.delegators?.resources?[pos.roomName]
    transform = transforms["#{path}"]
    x = pos.x - transform.x
    y = pos.y - transform.y
    resources["#{x},#{y}"].freeTiles |= path
    room = Game.rooms[pos.roomName]
    flags = room.lookForAt LOOK_FLAGS, pos.x, pos.y
    flag.remove() for flag in flags
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
    
    tiles = 0
    count = 0
    
    for transform in transformArray
      if isTileWalkable room, sourceX + transform.x, sourceY + transform.y
        tiles |= transform.path
        count++
    
    return {sourceID: source.id, freeTiles: tiles}

PATH =
  UP_LEFT: 1<<0
  UP: 1<<1
  UP_RIGHT: 1<<2
  LEFT: 1<<3
  RIGHT: 1<<4
  DOWN_LEFT: 1<<5
  DOWN: 1<<6
  DOWN_RIGHT: 1<<7

transforms =
  "#{PATH.UP_LEFT}": {x: -1, y: -1}
  "#{PATH.UP}": {x: 0, y: -1}
  "#{PATH.UP_RIGHT}": {x: 1, y: -1}
  "#{PATH.LEFT}": {x: -1, y: 0}
  "#{PATH.RIGHT}": {x: 1, y: 0}
  "#{PATH.DOWN_LEFT}": {x: -1, y: 1}
  "#{PATH.DOWN}": {x: 0, y: 1}
  "#{PATH.DOWN_RIGHT}": {x: 1, y: 1}

transformArray = [
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