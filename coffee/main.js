const util = require('util')

const roles = {
  harvester: require('role.harvester'),
}

module.exports.loop = function() {
  var i = 0
  
  util.resetCounts(roles)
  
  for (const name in Game.creeps) {
    console.log(`creep #${i++}: ${name}`)
    
    const creep = Game.creeps[name]
    const role = roles[creep.memory.role]
    
    if (role === undefined || role === null) {
      console.log(`Unsupported role '${creep.memory.role}' -- suiciding`)
      creep.suicide()
      continue
    }
    
    role.count++
    role.run(creep)
  }
  
  util.autoSpawn(roles)
  util.killExtras(roles)
}