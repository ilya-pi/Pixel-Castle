module(..., package.seeall)

SkyViewController = {clouds = true}

-- Constructor
function SkyViewController:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function SkyViewController:render(physics, world, game)	
	local sky = display.newRect(0, 0, game.worldWidth, game.worldHeight);
	sky:setFillColor(207, 229, 130)
	sky:setStrokeColor(207, 229, 130)
	world:insert(sky)

	for i=0,(game.worldWidth / game.pixel) do
		if (math.random(255) % 3 == 0) then
			local yPos = math.random(game.worldHeight / game.pixel)
			local cloud = display.newRect(i * game.pixel, yPos * game.pixel, game.pixel, game.pixel);
			cloud.strokeWidth = 0
			cloud:setFillColor(255, 255, 255)
			cloud:setStrokeColor(255, 255, 255)
			world:insert(cloud)
		end
	end

	print("Rendered sky with " .. tostring(game.worldWidth) .. ", " .. tostring(game.worldHeight))	
end
