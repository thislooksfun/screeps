###
thislooksfun's personal Screeps scripts
Copyright (C) 2016  thislooksfun

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

module.exports =
  
  countPerRoom: 6
  
  bodyForRoom: (room) ->
    maxEnergy = room.energyCapacityAvailable
    if maxEnergy > 3600
      maxEnergy = 3600 #Magic number to have 50 conponents (which is the max)
    partsMove = Math.floor maxEnergy / 50 / 5
    partsCarry = partsMove
    energyUsed = partsMove * 50
    energyUsed += partsCarry * 50
    partsWork = Math.floor (maxEnergy - energyUsed) / 100
    
    body = []
    for i in [0...partsWork]
      body.push WORK
    for i in [0...partsCarry]
      body.push CARRY
    for i in [0...partsMove]
      body.push MOVE
    return body
  
  run: (creep) ->
    if creep.memory.isWorking and creep.carry.energy is 0
      creep.memory.isWorking = false
    if not creep.memory.isWorking and creep.carry.energy is creep.carryCapacity
      creep.aiDoneHarvesting()
      creep.memory.isWorking = true
    
    if creep.memory.isWorking
      # TODO: Add upgrading in here?
      # TODO: Add task delegation? (x ticks and/or x creeps per task?)
      return if creep.aiRepairPriorityUrgent()
      return if creep.aiTransferEnergy()
      return if creep.aiBuild()
      return if creep.aiRepairPriorityHigh()
      return if creep.aiRepairPriorityMedium()
      return if creep.aiRepairPriorityLow()
      return if creep.aiRepairPriorityMinimal()
      return if creep.aiRepairAll()
    else
      creep.aiHarvest()
    return #Block auto-return