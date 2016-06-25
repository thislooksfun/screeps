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

resourceDelegator = require 'delegator.resource'

Creep::aiHarvest = ->
  source = Game.getObjectById(@memory.harvestTarget?.sourceID ? '')
  unless source and @room.lookForAt(LOOK_SOURCES, source)
    output = resourceDelegator.getFreeSourceHarvestLocationInRoom @room, @name
    @memory.harvestTarget = output
    return false unless @memory.harvestTarget?
    source = Game.getObjectById(@memory.harvestTarget?.sourceID ? '')
  
  return false unless source?
  
  if @harvest(source) is ERR_NOT_IN_RANGE
    @moveTo @memory.harvestTarget.pos.x, @memory.harvestTarget.pos.y
  return true

Creep::aiDoneHarvesting = ->
  if @memory.harvestTarget?
    resourceDelegator.stoppedHarvestingAt @memory.harvestTarget
    delete @memory.harvestTarget
  return true