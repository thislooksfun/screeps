module.exports =
  countPerRoom: 4
  body: [WORK, CARRY, MOVE] #TODO: make dynamic
  
  run: (creep) ->
    # TODO: Adapt work based on needed tasks
    # (energy supplies low, construction sites, low upgrader, etc)
    return #Block auto-return