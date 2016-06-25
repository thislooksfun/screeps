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

StructureTower::aiTick = ->
  return true if @aiAttack()
  return true if @aiHeal()
  return true if @aiRepair()
  return false

StructureTower::aiAttack = ->
  hostiles = @room.find FIND_HOSTILE_CREEPS
  return false unless hostiles.length > 0
  @attack hostiles[0]
  return true

StructureTower::aiHeal = ->
  lowHealth = (creep) -> return creep.hits < creep.hitsMax
  lowHealthCreeps = @room.find FIND_MY_CREEPS, {filter: lowHealth}
  return false unless lowHealthCreeps.length > 0
  lowHealthCreeps.sort (a, b) -> return a.hits - b.hits
  @heal lowHealthCreeps[0]
  return true

StructureTower::aiRepair = ->
  lowHealth = (struct) ->
    return false if struct.structureType is STRUCTURE_ROAD
    return false if struct.hits > 10000
    return struct.hits < struct.hitsMax
  lowHealthStructs = @room.find FIND_STRUCTURES, {filter: lowHealth}
  return false unless lowHealthStructs.length > 0
  lowHealthStructs.sort (a, b) -> return a.hits - b.hits
  @repair lowHealthStructs[0]
  return true