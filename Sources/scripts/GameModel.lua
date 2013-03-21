module(..., package.seeall)

GameModel = {delay = 100,
	pixel = 10,
	worldWidth = 1000,
	worldHeight = 600,
	castleWidth = 10, -- in Pixel  todo castle width should be dynamic
	castleHeight = 10, -- in Pixel todo castle height should be dynamic
	groundYOffset = 3,
	castle1xOffset = 5, -- in Pixel
	castle2xOffset = 70, -- in Pixel
	cannonYOffset = 5, -- in Pixel
	cameraState = "CASTLE1_FOCUS", -- "CASTLE2_FOCUS", "CANNONBALL_FOCUS", "FOCUSING"
	state = "PLAYER1", -- "PLAYER2", "PLAYER1_LOST", "PLAYER2_LOST"
	minCastleHealth = 70
	}	

-- Constructor
function GameModel:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
-- function GameModel:render(physics, world)	
-- 	local test = display.newRect(200, 200, 27, 27);
-- 	test:setFillColor(26, 55, 37)
-- 	test:setStrokeColor(26, 55, 37)
-- 	test.myName = "brick"
-- 	world:insert(test)
-- 	physics.addBody(test, "static")

-- 	print("Rendered earth with " .. tostring(self.width) .. ", " .. tostring(self.height))
-- 	-- print("test")
-- end