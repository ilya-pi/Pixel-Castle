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
	for i=0,game.level_map.level.width do
		for l=0,game.level_map.level.height do
			local r, g, b, a = imageHelper.pixel(i, l, game.level_map.level)
			-- Is it pink and should we render castle then?
			if (r == 255 and g == 0 and b == 255 and a == 255) then
				local castleY = game.level_map.level.height - l
				if (self.castleCount == 1) then
					print("render first castle")
					game.castle1 = castle_module.CastleViewController:new{castleName = "castle1", location = "left"}
					game.castle1.yLevel = castleY + 1
					game.castle1.absX = i * game.pixel
					game.castle1.absY = game.castle1.yLevel * game.pixel
					game.castle1:render(physics, world, game, i - 1, castleY)
				elseif (self.castleCount == 2) then
					print("render second castle")
					game.castle2 = castle_module.CastleViewController:new{castleName = "castle2", location = "right"}
					game.castle2.yLevel = castleY + 1
					game.castle2.absX = i * game.pixel
					game.castle2.absY = game.castle2.yLevel * game.pixel			
					game.castle2:render(physics, world, game, i - 1, castleY)
				end
				self.castleCount = self.castleCount + 1
			elseif (a ~= 0) then
				local grass = display.newRect(i * game.pixel, l * game.pixel, game.pixel, game.pixel)
				world:insert(grass)
				grass.myName = "brick"
				grass.strokeWidth = 0
				grass:setFillColor(r, g, b)
				grass:setStrokeColor(r, g, b)				
				physics.addBody(grass, "static")
			end
		end
	end

	print("Rendered earth with " .. tostring(self.width) .. ", " .. tostring(self.height))	
end
