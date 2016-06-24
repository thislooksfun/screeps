module.exports =
  
  countPerRoom: 0
  
  bodyForRoom: (room) ->
    return [ATTACK, ATTACK, RANGED_ATTACK, TOUGH, TOUGH, TOUGH, TOUGH, MOVE, MOVE]
  
  ### @param {Creep} creep ###
  run: (creep) ->
    return #Block auto-return