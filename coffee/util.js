module.exports = {
  autoSpawn: function(roles) {
    for (let rn in roles) {
      const role = roles[rn]
      console.log(`${rn}.count = ${role.count}`)
      if (role.count < role.minCount) {
        role.spawnNew()
      }
    }
  },
  resetCounts: function(roles) {
    for (let rn in roles) {
      roles[rn].count = 0
    }
  },
  killExtras: function(roles) {
    for (let rn in roles) {
      const role = roles[rn]
      if (role.count > role.maxCount) {
        role.killOne()
      }
    }
  }
}