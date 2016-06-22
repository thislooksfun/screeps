module.exports =
  
  loadResourcesForRoom: (room) ->
    Game.memory.delegators ?= {}
    Game.memory.delegators.resources ?= {}
    resources = Game.memory.delegators.resources
    resources[room.name] = 'hello world'
    
    console.log resources
    
    return #Block auto-return