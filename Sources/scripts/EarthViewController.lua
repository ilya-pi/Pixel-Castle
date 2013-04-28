module(..., package.seeall)

EarthViewController = {}

local castle_module = require("scripts.CastleViewController")
local imageHelper = require("scripts.util.Image")

-- Constructor
function EarthViewController:new (o)
	o = o or {castleCount = 1}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function EarthViewController:render(physics, world, game)
	local yLimit = game.level_map.height / ( 2 * game.pixel )
	local prevY = calculateYGround(5, 0, game)
	local nY = game.groundYOffset + prevY	

	for i=0,(game.level_map.width / game.pixel) do
		local shouldRenderCastle = false
		local castleY = 0
		for l=0,game.level_height do
			local r, g, b, a = game.level_map:pixel(i, l, "level")
			if (r == 255 and g == 0 and b == 255) then
				shouldRenderCastle = true
				castleY = l				
			elseif (a != 1) then
				local grass = display.newRect(i * game.pixel, l * game.pixel, game.pixel, game.pixel)
				world:insert(grass)
				grass.myName = "brick"
				grass.strokeWidth = 0
				grass:setFillColor(r, g, b)
				grass:setStrokeColor(r, g, b)				
			end
			physics.addBody(grass, "static")
		end

		if (shouldRenderCastle) then
			if (self.castleCount == 1) then
				game.castle1 = castle_module.CastleViewController:new{castleName = "castle1", location = "left"}
				game.castle1.yLevel = l + 1
				game.castle1.absX = i * game.pixel
				game.castle1.absY = game.castle1.yLevel * game.pixel
				game.castle1:render(physics, world, game, i, l + 1)
			elseif
				game.castle2 = castle_module.CastleViewController:new{castleName = "castle2", location = "right"}
				game.castle2.yLevel = l + 1
				game.castle2.absX = i * game.pixel
				game.castle2.absY = game.castle2.yLevel * game.pixel			
				game.castle2:render(physics, world, game, i, l + 1)				
			end
			self.castleCount = self.castleCount + 1
			shouldRenderCastle = false
		end
	end

	print("Rendered earth with " .. tostring(self.width) .. ", " .. tostring(self.height))	
end
