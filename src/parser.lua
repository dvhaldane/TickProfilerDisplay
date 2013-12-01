--[[

	TickProfiler JSON Data Parser Version 1.0 Alpha
	Do not modify, copy or distribute without permission of author
	Helkarakse, 20131128
	
	Changelog:
	- 1.0 Added all the methods
	
]]

-- following json format, first key is tps, 
-- second key is array for single entity, 
-- third key is array for chunk,
-- fourth key is array for entity by type,
-- fifth key is array for average entity

-- Libraries
os.loadAPI("json")
os.loadAPI("functions")

-- Vars
local stringData, tableData, tableTps, tableSingleEntity, tableChunk, tableEntityByType, tableAverageCalls

-- Main Functions
-- Parses the json string and initializes each table variable. Returns true on successful parse, false on empty string passed.
function parseData(stringInput)
	if (stringInput == "") then
		return false
	else
		stringData = stringInput
		tableData = json.decode(stringData)
		
		tableTps = tableData[1]
		tableSingleEntity = tableData[2]
		tableChunk = tableData[3]
		tableEntityByType = tableData[4]
		tableAverageCalls = tableData[5]
		return true
	end
end

-- TPS
-- Returns the exact tps value as listed in the profile
function getExactTps()
	local tpsValue = ""
	for k, v in pairs(tableTps) do
		tpsValue = v
	end
	
	return tpsValue
end

-- Rounds the tps value to given decimal places and returns it
-- Fixed, but not accurately rounding the number (using strsub method)
function getTps()
	-- return roundTo(getExactTps(), (places or 2))
	return string.sub(getExactTps(), 1, 5)
end

-- SingleEntities
-- Returns a table containing single entities that cause lag. 
-- Each row is a table containing the following keys: 
-- percent: percentage of time/tick, time: time/tick, name: name of entity, position: position of entity, dimension: dimension containing entity
function getSingleEntities()
	local returnTable = {}
	
	for key, value in pairs(tableSingleEntity) do
		local row = {}
		row.percent = value["%"]
		row.time = value["Time/Tick"]
		
		local nameTable = functions.explode(" ", value["Single Entity"])
		-- the first part of the name contains the actual entity name
		row.name = nameTable[1]
		
		local dimTable = functions.explode(":", value["Single Entity"])
		row.dimension = dimTable[2]
		
		-- strip off the dimension from the position
		local position = nameTable[2]
		local dimCharCount = string.len(row.dimension)
		row.position = string.sub(position, 0, string.len(position) - (dimCharCount + 1))
		
		
		table.insert(returnTable, row)
	end
	
	return returnTable
end

-- Chunks
-- Returns a table containing the chunks that cause lag.
-- Each row is a table containing the following keys:
-- percent: percentage of time/tick, time: time/tick, positionX: X coordinate of chunk, positionZ: Z coordinate of chunk
function getChunks()
	local returnTable = {}
	
	for key, value in pairs(tableChunk) do
		local row = {}
		row.percent = value["%"]
		row.time = value["Time/Tick"]
		
		local chunkTable = functions.explode("\, ", value["Chunk"])
		local chunkX = tonumber(chunkTable[1])
		local chunkZ = tonumber(chunkTable[2])
		
		local realX = chunkX * 16
		local realZ = chunkZ * 16
		
		row.positionX = realX
		row.positionZ = realZ
		
		table.insert(returnTable, row)
	end
	
	return returnTable
end

-- EntityByTypes
-- Returns a table containing the types of entities causing the most lag
-- Each row is a table containing the following keys:
-- percent: percentage of time/tick, time: time/tick, type: the type of entity that is listed
function getEntityByTypes()
	local returnTable = {}
	
	for key, value in pairs(tableEntityByType) do
		local row = {}
		row.percent = value["%"]
		row.time = value["Time/Tick"]
		row.type = value["All Entities of Type"]
		
		table.insert(returnTable, row)
	end
	
	return returnTable
end

-- AverageCallsPerEntity
-- Returns a table containing the top average calls made by specific entities
-- Each row is a table containing the following keys:
-- name: name of entity, time: time/tick, calls: number of calls made

function getAverageCalls()
	local returnTable = {}
	
	for key, value in pairs(tableAverageCalls) do
		local row = {}
		row.time = value["Time/tick"]
		row.name = value["Average Entity of Type"]
		row.calls = value["Calls"]
		
		table.insert(returnTable, row)
	end
	
	return returnTable
end