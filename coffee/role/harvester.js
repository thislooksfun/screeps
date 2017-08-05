module.exports = {
  minCount: 1,
  maxCount: Infinity,
  
  run: function(creep) {
    console.log(`${creep.name} -- harvesting`)
    
    if (creep.memory.mode === 'drop-off') {
      // Drop off at spawn
      // TODO: Get spawn dynamically
      if (creep.transfer(Game.spawns.Spawn1, RESOURCE_ENERGY) === ERR_NOT_IN_RANGE) {
        creep.moveTo(Game.spawns.Spawn1)
      } else if (creep.carry.energy === 0) {
        creep.memory.mode = 'harvest'
      }
    } else {
      // Harvest
      const sourceID = creep.memory.sourceID
      var energySource = undefined
      if (sourceID == null) {
        const source = creep.pos.findClosestByPath(FIND_SOURCES)
        creep.memory.sourceID = source.id
        energySource = source
      } else {
        energySource = Game.getObjectById(sourceID)
      }
      
      if (creep.harvest(energySource) === ERR_NOT_IN_RANGE) {
        creep.moveTo(energySource)
      } else if (creep.carry.energy === creep.carryCapacity) {
        creep.memory.mode = 'drop-off'
      }
    }
  },
  
  spawnNew: function() {
    Game.spawns.Spawn1.createCreep([WORK, CARRY, MOVE, MOVE], `Harvester`, {role: 'harvester'})
  },
}