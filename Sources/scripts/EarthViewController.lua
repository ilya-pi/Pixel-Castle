module(..., package.seeall)

EarthViewController = {}

local castle_module = require("scripts.CastleViewController")	

-- print(Earth.width)	

-- Constructor
function EarthViewController:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

local function calculateYGround(prevY, x, game)
	local result = prevY
	if ((x >= game.castle1xOffset and x <= game.castle1xOffset + game.castleWidth) 
		or (x >= game.castle2xOffset and x <= game.castle2xOffset + game.castleWidth)) then
		return result
	else
		if (math.random(10) % 2 == 1) then
			result = result + math.random(16) % 3
		else
			result = result - math.random(16) % 3
		end

		if (result > game.worldHeight / game.pixel) then
			result = game.worldHeight / game.pixel
		end
		if (result < 0) then
			result = 0
		end

		return result
	end
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function EarthViewController:render(physics, world, game)	
	local yLimit = game.worldHeight / ( 2 * game.pixel )
	local prevY = calculateYGround(5, 0, game)
	local nY = game.groundYOffset + prevY	

	for i=0,(game.worldWidth / game.pixel) do
		for l=0,nY do
			local current = i * 10 + l;
			local grass = display.newRect(i * game.pixel, game.worldHeight - l * game.pixel, game.pixel, game.pixel)
			world:insert(grass)
			grass.myName = "brick"
			grass.strokeWidth = 0
			if (l == nY or math.random(255) % 17 == 0) then
				grass:setFillColor(66, 110, 44)
				grass:setStrokeColor(66, 110, 44)
			else
				grass:setFillColor(159, 186, 49)
				grass:setStrokeColor(159, 186, 49)				
			end

			physics.addBody(grass, "static")
		end
		prevY = calculateYGround(prevY, i, game)
		nY = game.groundYOffset + prevY		

		if (i == game.castle1xOffset + 1) then
			game.castle1 = castle_module.CastleViewController:new()
			game.castle1.yLevel = nY + 1
			game.castle1.absX = i * game.pixel
			game.castle1.absY = game.castle1.yLevel * game.pixel
			game.castle1:render(physics, world, game, i, nY + 1)
		end

		if (i == game.castle2xOffset + 1) then
			game.castle2 = castle_module.CastleViewController:new()
			game.castle2.yLevel = nY + 1
			game.castle2.absX = i * game.pixel
			game.castle2.absY = game.castle2.yLevel * game.pixel			
			game.castle2:render(physics, world, game, i, nY + 1)
		end		
	end

	print("Rendered earth with " .. tostring(self.width) .. ", " .. tostring(self.height))	
end
