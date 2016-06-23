module.exports =
  countPerRoom: 4
  body: ->
    #TODO: make dynamic
    return [WORK, CARRY, MOVE]
  
  run: (creep) ->
    # TODO: Adapt work based on needed tasks
    # (energy supplies low, construction sites, low upgrader, etc)
    return #Block auto-return