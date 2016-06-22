delegators =
  resource: require('delegator.resource')

roles =
  harvester: require('role.harvester')
  upgrader: require('role.upgrader')
  builder: require('role.builder')
  warrior: require('role.warrior')

require('extension.base')
require('extension.harvest')
# require('extension.transfer')
require('extension.build')
# require('extension.upgrade')

module.exports.loop = ->
  
  purgeMemory()
  
  if Game.spawns.Spawn1.room.find(FIND_CONSTRUCTION_SITES).length is 0
    roles.builder.countPerRoom = 1
    roles.upgrader.countPerRoom = 3
    
  
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
      didSpawn = true if ensureMin(roleName, min, role.body)
    unless roleName is 'harvester' and max <= 0
      purgeMax(roleName, max)
    else
      console.err 'Aborted -- tried to purge the last harvester!'


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
      delete Memory.creeps[name]
  return #Block auto-return