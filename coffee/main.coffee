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
require('extension.structure.storage')

module.exports.loop = ->
  
  delegators.resource.loadResources()
  
  purgeMemory()
  processMinMax()
  
  for name, creep of Game.creeps
    roles[creep.memory.role]?.run creep
  return #Block auto-return


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
      didSpawn = true if ensureMin(roleName, min, role.body())
    if roleName is 'worker' and max <= 0
      console.error 'Aborted -- tried to purge the last worker!'
    else
      purgeMax(roleName, max)

ensureMin = (role, minCount, body) ->
  inRole = _.filter Game.creeps, (creep) -> return creep.memory.role is role
  if inRole.length < minCount
    result = Game.spawns.Spawn1.createCreep body, null, {role: role}
    if typeof result is 'string'
      console.log "Spawning new #{role}: #{result}"
      return true
    else
      console.log "error spawning new #{role}: #{result}"
      # energyToSpawn = 0; //TODO: Figure out how to calculate this
      # enertyRatio = "#{Game.spawns.Spawn1.energy}/#{energyToSpawn}"
      # console.log "Insufficient energy for spawning new upgrader #{enertyRatio}"
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


# droneCost = (attrList) ->
#   return unless attrList?
#   sum = 0
#   for attr in attrList
#     sum += BODYPART_COST[attr]
#   return sum
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
#
# buildOptimizedWorker = (currentRoom) ->
#   maxEnergy = currentRoom.energyCapacityAvailable
#   partsMove = Math.floor maxEnergy / 50 / 5
#   partsCarry = partsMove
#   energyUsed = partsMove * 50
#   energyUsed += partsCarry * 50
#   partsWork = Math.floor (maxEnergy - energyUsed) / 100
#   body = []
#
#   for i in [0...partsMove]
#     body.push MOVE
#   for i in [0...partsCarry]
#     body.push CARRY
#   for i in [0...partsWork]
#     body.push WORK
#
#   return body