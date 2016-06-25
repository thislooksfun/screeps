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

Creep::aiTransfer = (type, isValidStorageStructure, sortStorage) ->
  energy_containers = @room.find FIND_STRUCTURES, {filter: isValidStorageStructure}
  
  if sortStorage?
    energy_containers.sort sortStorage
  
  if energy_containers.length > 0
    if @transfer(energy_containers[0], RESOURCE_ENERGY) is ERR_NOT_IN_RANGE
      @moveTo energy_containers[0]
    return true
  
  return false


# hightest # = hightest priority
energyContainerPreference =
  "#{STRUCTURE_SPAWN}": 3
  "#{STRUCTURE_EXTENSION}": 3
  "#{STRUCTURE_TOWER}": 2
  "#{STRUCTURE_CONTAINER}": 1
  "#{STRUCTURE_STORAGE}": 1

Creep::aiTransferEnergy = ->
  filter = (structure) -> return structure.canStoreMoreEnergy()
  sort = (a, b) ->
    apref = energyContainerPreference[a.structureType] or 0
    bpref = energyContainerPreference[b.structureType] or 0
    return bpref - apref
  return @aiTransfer RESOURCE_ENERGY, filter, sort