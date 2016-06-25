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

Creep::aiRepair = (healthFilter) ->
  targets = @room.find FIND_STRUCTURES, {filter: healthFilter}
  
  return false unless targets.length > 0
  
  targets.sort (a, b) =>
    diff = a.hits - b.hits
    return diff unless diff is 0
    return @distanceTo(a.pos) - @distanceTo(b.pos)
  
  if @repair(targets[0]) is ERR_NOT_IN_RANGE
    @moveTo targets[0]
  return true

Creep::aiRepairPercent = (percent) ->
  return @aiRepair (structure) -> return structure.hits < (structure.hitsMax * (percent / 100))

Creep::aiRepairLeveledAmount = (healthPerWork) ->
  return @aiRepair (struct) =>
    return struct.hits < (healthPerWork * @partCount(WORK)) and struct.hits < struct.hitsMax

Creep::aiRepairPriorityUrgent = -> return @aiRepairLeveledAmount 500
Creep::aiRepairPriorityHigh = -> return @aiRepairLeveledAmount 2500
Creep::aiRepairPriorityMedium = -> return @aiRepairPercent 25
Creep::aiRepairPriorityLow = -> return @aiRepairPercent 50
Creep::aiRepairPriorityMinimal = -> return @aiRepairPercent 75

Creep::aiRepairAll = ->
  return @aiRepair (structure) ->
    return structure.hits < structure.hitsMax