--[[
 
        TickProfiler Basic Version 1.0 Alpha
        Do not modify, copy or distribute without permission of author
        Helkarakse-Shotexpert, 20131201
 
]]

-- Libraries
os.loadAPI("parser")
os.loadAPI("functions")

-- Variables
local monitor
local slideDelay = 5
local refreshDelay = 60
local jsonFile = "profile.txt"

-- Functions
local function getTps()
	local tps = tonumber(parser.getTps())
	return tps, parser.getTpsColor(tps)
end

-- Display
local function displayHeader()
	local xPos = 2
	local yPos = 2
	local tps, tpsColor = getTps()
	
	monitor.setCursorPos(xPos, yPos)
	monitor.write("OTE-Gaming Tickboard of Shame")
	monitor.setCursorPos(xPos, yPos + 1)
	monitor.write("Powered by Helk & Shot")
	monitor.setCursorPos(xPos, yPos + 3)
	monitor.write("Global TPS: ")
	monitor.setCursorPos(xPos + 12, yPos + 3)
	monitor.setTextColor(tpsColor)
	monitor.write(tps)
	monitor.setTextColor(colors.white)
end

local function displayDataHeading(id)
	local yPos = 7
	
	if (id == 1) then
		-- id 1 = the single entity list
		monitor.setCursorPos(2, yPos)
		monitor.write("Name:")
		monitor.setCursorPos(26, yPos)
		monitor.write("X - Y - Z:")
		monitor.setCursorPos(41, yPos)
		monitor.write("%")
		monitor.setCursorPos(53, yPos)
		monitor.write("Dimension:")
	elseif (id == 2) then
		-- id 2 = the chunk list
	elseif (id == 3) then
		-- id 3 = the type list
	elseif (id == 4) then
		-- id 4 = the call list
	end
end

local function displayData(id)
	local yPos = 8
	if (id == 1) then
		local singleEntities = parser.getSingleEntities()
		for i = 1, 10 do
			monitor.setCursorPos(2, yPos)
			monitor.write(singleEntities[i].name)
			monitor.setCursorPos(26, yPos)
			monitor.write(singleEntities[i].position)
			monitor.setCursorPos(41, yPos)
			 
			local percentage = tonumber(singleEntities[i].percent)
			monitor.setTextColor(parser.getPercentColor(percentage))
			monitor.write(percentage)
			monitor.setTextColor(colors.white)
			
			-- dimensions
			monitor.setCursorPos(53, yPos)
			if (tonumber(singleEntities[i].dimId) == 11) then
				monitor.write("Gold Mining Age")
			else
				monitor.write(singleEntities[i].dimension)
			end
			
			yPos = yPos + 1
		end
	elseif (id == 2) then
		-- id 2 = the chunk list
	elseif (id == 3) then
		-- id 3 = the type list
	elseif (id == 4) then
		-- id 4 = the call list
	end
end

-- Loops
local refreshLoop = function()
	while true do
		local file = fs.open(jsonFile, "r")
		local text = file.readAll()
		file.close()
		
		parser.parseData(text)
		functions.debug("Refreshing data.")
		displayDataHeading(1)
		displayData(1)
		functions.debug("Refreshing screen.")
		sleep(refreshDelay)
	end
end

local slideLoop = function()
	
end

local function init()
	local monFound, monDir = functions.locatePeripheral("monitor")
	if (monFound == true) then
		monitor = peripheral.wrap(monDir)
	else
		functions.debug("A monitor is required to use this program.")
		return
	end
	
	local file = fs.open(jsonFile, "r")
	local text = file.readAll()
	file.close()
	parser.parseData(text)
	
	monitor.clear()
	displayHeader()
	displayDataHeading(1)
	displayData(1)
	
	parallel.waitForAll(slideLoop, refreshLoop)
end

init()
