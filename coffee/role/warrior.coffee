module.exports =
  
  countPerRoom: 0
  
  bodyForRoom: (room) ->
    return [TOUGH, TOUGH, TOUGH, TOUGH, RANGED_ATTACK, ATTACK, ATTACK, MOVE, MOVE]
  
  ### @param {Creep} creep ###
  run: (creep) ->
    return #Block auto-return