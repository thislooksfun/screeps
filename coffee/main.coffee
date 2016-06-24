delegators =
  resource: require('delegator.resource')

roles =
  worker: require 'role.worker'
  upgrader: require('role.upgrader')
  warrior: require('role.warrior')

require('extension.creep.base')
require('extension.creep.harvest')
require('extension.creep.transfer')
require('extension.creep.build')
require('extension.creep.upgrade')
require('extension.creep.repair')
require('extension.structure.storage')

module.exports.loop = ->
  
  delegators.resource.loadResources()
  
  purgeMemory() if timeForNext 'memoryPurge', 20
  processMinMax() if timeForNext 'processMinMax', 5
  
  
  for name, creep of Game.creeps
    roles[creep.memory.role]?.run creep
  
  Memory.tickAverages ?= []
  Memory.tickAverages.push Game.cpu.getUsed()
  while Memory.tickAverages.length > 20
    Memory.tickAverages.shift()
  
  if timeForNext 'logCPU', 30
    limit = "limit: #{Game.cpu.limit}"
    tickLimit = "tickLimit: #{Game.cpu.tickLimit}"
    bucket = "bucket: #{Game.cpu.bucket}"
    tickAvg = round(_.sum(Memory.tickAverages) / Memory.tickAverages.length, 3)
    avg = "tick average: #{tickAvg} cpu"
    if tickAvg > 10
      Game.notify "Cpu average over the last 20 ticks was higher than 10! (#{tickAvg})"
    console.log "#{limit}; #{tickLimit}; #{bucket}; #{avg}"
  
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
      didSpawn = true if ensureMin(Game.rooms['W11N26'], roleName, min, role.bodyForRoom)
    if roleName is 'worker' and max <= 0
      console.error 'Aborted -- tried to purge the last worker!'
    else
      purgeMax(roleName, max)

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
#
# getOptimalBody = (spawn) ->
#   body = []
#   stats = spawnUtility.getSpawnStats spawn
#
#   carryPart = Math.ceil(stats.parts / 5);
#
#   for (var i = 0; i < carryPart; i++)
#     body.push(MOVE)
#     body.push(CARRY)
#
#   while spawnUtility.getBodyCost(body) < stats.energy && body.length < stats.parts
#     body.push(MOVE)
#     body.push(WORK)
#
#   while spawnUtility.getBodyCost(body) > stats.energy || body.length > stats.parts
#     body.pop()
#
#   return body

round = (value, precision) ->
  multiplier = Math.pow(10, precision or 0)
  return Math.round(value * multiplier) / multiplier