delegators =
  resource: require 'delegator.resource'

roles =
  worker: require 'role.worker'
  upgrader: require 'role.upgrader'
  warrior: require 'role.warrior'

require 'extension.creep.base'
require 'extension.creep.harvest'
require 'extension.creep.transfer'
require 'extension.creep.build'
require 'extension.creep.upgrade'
require 'extension.creep.repair'

require 'extension.room'
require 'extension.structure.storage'
require 'extension.structure.tower'

module.exports.loop = ->
  
  delegators.resource.loadResources()
  
  purgeMemory() if timeForNext 'memoryPurge', 20
  processMinMax() if timeForNext 'processMinMax', 5
  alertLowBuildSites() if timeForNext 'alertLowBuildSites', 60
  convertFlagsToBuildSites() if timeForNext 'convertFlagsToBuildSites', 60
  upgradeRoomsToMatchRCL() if timeForNext 'upgradeRoomsToMatchRCL', 60
  
  for name, creep of Game.creeps
    roles[creep.memory.role]?.run creep
  
  # TODO: Do this for all rooms
  isTower = {structureType: STRUCTURE_TOWER}
  towers = Game.spawns.Spawn1.room.find FIND_MY_STRUCTURES, {filter: isTower}
  for tower in towers
    tower.aiTick()
  
  Memory.tickAverages ?= []
  Memory.tickAverages.push Game.cpu.getUsed()
  while Memory.tickAverages.length > 20
    Memory.tickAverages.shift()
  
  logCPU() if timeForNext 'logCPU', 30
  
  return #Block auto-return


timeForNext = (name, every = 10) ->
  Memory.next ?= {}
  if not Memory.next[name]? or Memory.next[name] <= 0
    Memory.next[name] = every
    return true
  
  Memory.next[name]--
  return false


processMinMax = ->
  didSpawn = false
  for roleName, role of roles
    min = role.minCountPerRoom or role.countPerRoom
    unless min?
      console.err "minCountPerRoom or countPerRoom must be defined (role: #{roleName})"
      continue
    max = role.maxCountPerRoom or role.countPerRoom
    unless max?
      console.err "maxCountPerRoom or countPerRoom must be defined (role: #{roleName})"
      continue
    if max < min
      console.err "max must be >= min (role: #{roleName} - max: #{max}, min: #{min})"
      continue
    
    unless didSpawn
      #TODO: Multi-room / multi-spawn support
      didSpawn = true if ensureMin(Game.spawns.Spawn1.room, roleName, min, role.bodyForRoom)
    if roleName is 'worker' and max <= 0
      console.error 'Aborted -- tried to purge the last worker!'
    else
      purgeMax(roleName, max)
  return #Block auto-return

ensureMin = (room, role, minCount, getBody) ->
  #TODO: Use room info
  inRole = _.filter Game.creeps, (creep) -> return creep.memory.role is role
  if inRole.length < minCount
    body = getBody room
    result = Game.spawns.Spawn1.createCreep body, null, {role: role}
    if typeof result is 'string'
      console.log "Spawning new #{role}: #{result} - body: [#{body}]"
      return true
    else
      switch result
        when ERR_BUSY
          console.log "error spawning new #{role}: Spanwer in use!"
        when ERR_NOT_ENOUGH_ENERGY
          energyToSpawn = creepCost body
          enertyRatio = "#{Game.spawns.Spawn1.energy}/#{energyToSpawn}"
          console.log "Insufficient energy for spawning new #{role}: #{enertyRatio}"
        else
          console.log "error spawning new #{role}: #{result}"
  return false


purgeMax = (role, maxCount) ->
  inRole = _.filter Game.creeps, (creep) -> return creep.memory.role is role
  over = inRole.length - maxCount
  while over > 0
    inRole[over - 1].suicide()
    over--
  return #Block auto-return


purgeMemory = ->
  for name of Memory.creeps
    if not Game.creeps[name]?
      if Memory.creeps[name].harvestTarget?
        delegators.resource.stoppedHarvestingAt Memory.creeps[name].harvestTarget
      delete Memory.creeps[name]
  return #Block auto-return


creepCost = (attrList) ->
  return unless attrList?
  sum = 0
  for attr in attrList
    sum += BODYPART_COST[attr]
  return sum

round = (value, precision) ->
  multiplier = Math.pow(10, precision or 0)
  return Math.round(value * multiplier) / multiplier


logCPU = ->
  limit = "limit: #{Game.cpu.limit}"
  tickLimit = "tickLimit: #{Game.cpu.tickLimit}"
  bucket = "bucket: #{Game.cpu.bucket}"
  tickAvg = round(_.sum(Memory.tickAverages) / Memory.tickAverages.length, 3)
  avg = "tick average: #{tickAvg} cpu"
  if tickAvg > 10 and Memory.lastTickAvg > 10
    line1 = 'Cpu average has sustained over 10 cpu for two cycles'
    line2 = "(current: #{tickAvg}; last: #{Memory.lastTickAvg})"
    Game.notify "#{line1} #{line2}"
  Memory.lastTickAvg = tickAvg
  console.log "#{limit}; #{tickLimit}; #{bucket}; #{avg}"
  return #Block auto-return

alertLowBuildSites = ->
  siteCount = _.size Game.constructionSites
  if siteCount < 10
    Game.notify(
      "Only #{siteCount} constructionSites left! You should schedule more!",
      60 #Group for 1 hour
    )
  return #Block auto-return

convertFlagsToBuildSites = ->
  for flagName, flag of Game.flags
    continue unless flagName.startsWith 'build_'
    building = flagName.substring 6, flagName.lastIndexOf '_'
    res = flag.room.createConstructionSite(flag.pos, building)
    switch res
      when ERR_FULL, ERR_RCL_NOT_ENOUGH
        flag.setColor COLOR_ORANGE, COLOR_RED
      else
        #Remove the flag if it the const site was added or is impossible to place
        flag.remove()
  return #Block auto-return



upgradeRoomsToMatchRCL = ->
  for roomName, room of Game.rooms
    addNewExtensionsInRoom room
  return #Block auto-return

addNewExtensionsInRoom = (room) ->
  extensionFilter = {structureType: STRUCTURE_EXTENSION}
  extensionsCount = room.find(FIND_MY_STRUCTURES, {filter: extensionFilter}).length
  extensionsCount += room.find(FIND_MY_CONSTRUCTION_SITES, {filter: extensionFilter}).length
  needed = CONTROLLER_STRUCTURES[STRUCTURE_EXTENSION][room.controller.level] - extensionsCount
  return unless needed > 0
  spawnFilter = {structureType: STRUCTURE_SPAWN}
  spawn = room.find(FIND_MY_STRUCTURES, {filter: spawnFilter})[0]
  return unless spawn?
  center = spawn.pos
  squareSize = 1
  while needed > 0
    squareSize += 4
    half = Math.floor squareSize / 2
    for x in [-half..half]
      for y in [-half..half]
        continue unless Math.abs(x) is half or Math.abs(y) is half #Only use the edges
        if Math.abs(x) is half and Math.abs(y) is half #Fill the corners with roads, not extensions
          res = room.createConstructionSite(center.x + x, center.y + y, STRUCTURE_ROAD)
          switch res
            when OK, ERR_INVALID_TARGET, ERR_INVALID_ARGS then continue
            else needed = -1 #something's gone wrong, abort
        else
          continue if needed <= 0
          res = room.createConstructionSite(center.x + x, center.y + y, STRUCTURE_EXTENSION)
          switch res
            when OK then needed--
            when ERR_INVALID_TARGET, ERR_INVALID_ARGS then continue
            else needed = -1 #something's gone wrong, abort
  
  squareSize += 6
  while squareSize > 0
    squareSize -= 4
    half = Math.floor squareSize / 2
    for x in [-half..half]
      for y in [-half..half]
        continue unless Math.abs(x) is half or Math.abs(y) is half #Only use the edges
        room.createConstructionSite(center.x + x, center.y + y, STRUCTURE_ROAD)
  return #Block auto-return