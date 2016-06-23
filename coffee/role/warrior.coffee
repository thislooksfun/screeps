module.exports =
  
  body: ->
    return [ATTACK, ATTACK, RANGED_ATTACK, MOVE, MOVE]
  
  countPerRoom: 0
  
  ### @param {Creep} creep ###
  run: (creep) ->
    return #Block auto-return