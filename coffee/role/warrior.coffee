module.exports =
  
  bodyForRoom: (room) ->
    return [ATTACK, ATTACK, RANGED_ATTACK, TOUGH, TOUGH, TOUGH, TOUGH, MOVE, MOVE]
  
  countPerRoom: 0
  
  ### @param {Creep} creep ###
  run: (creep) ->
    return #Block auto-return