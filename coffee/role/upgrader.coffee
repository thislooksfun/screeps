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
  
  countPerRoom: 2
  
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
  
  ### @param {Creep} creep ###
  run: (creep) ->
    if creep.memory.isUpgrading and creep.carry.energy is 0
      creep.memory.isUpgrading = false
    if not creep.memory.isUpgrading and creep.carry.energy is creep.carryCapacity
      creep.memory.isUpgrading = true
    
    if creep.memory.isUpgrading
      creep.aiDoneHarvesting()
      creep.aiUpgrade()
    else
      creep.aiHarvest()
    return #Block auto-return