module(..., package.seeall)

Camera = {game = nil, world = nil, sky = nil, background = nil}

-- Constructor
-- Requires object with game, world and display parametres
--todo: refactor code duplication
function Camera:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

local function calculateX(desiredX, game)
	if (desiredX + display.screenOriginX < display.contentWidth / 2) then
		return display.screenOriginX
	elseif (desiredX - display.screenOriginX > game.worldWidth - display.contentWidth / 2) then
		return - display.screenOriginX - (game.worldWidth - display.contentWidth)
	else
		return - desiredX + display.contentWidth / 2
	end
end

local function calculateY(desiredY, game)
	if (desiredY + display.screenOriginY < display.contentHeight / 4) then
        --print("1")
		return display.screenOriginY
	elseif (desiredY - display.screenOriginY > game.worldHeight - 3 * display.contentHeight / 4) then
        --print("2")
		return  - display.screenOriginY - (game.worldHeight - display.contentHeight)
    else
        --print("3")
		return - desiredY + display.contentHeight / 4
	end	
end

-- Camera follows bolder automatically
function Camera:moveCamera()		
	if (self.game.cameraState == "CASTLE1_FOCUS") then		
		if (self.game.castle1 ~= nil) then
			local cannonX = self.game.castle1:cannonX()
			local cannonY =  self.game.castle1:cannonY()
			transition.to(self.world, {time = 100, x = calculateX(cannonX, self.game), y = calculateY(cannonY, self.game), onComplete = self.listener})
			transition.to(self.sky, {time = 100, x = calculateX(cannonX, self.game) * self.sky.distanceRatio, y = calculateY(cannonY, self.game), onComplete = self.listener})
			transition.to(self.background, {time = 100, x = calculateX(cannonX, self.game) * self.background.distanceRatio, y = calculateY(cannonY, self.game), onComplete = self.listener})
			self.game.cameraState = "FOCUSING"
		end	
	elseif (self.game.cameraState == "CASTLE2_FOCUS") then
		if (self.game.castle2 ~= nil) then
			local cannonX = self.game.castle2:cannonX()
			local cannonY =  self.game.castle2:cannonY()
			transition.to(self.world, {time = 100, x = calculateX(cannonX, self.game), y = calculateY(cannonY, self.game), onComplete = self.listener})
			transition.to(self.sky, {time = 100, x = calculateX(cannonX, self.game) * self.sky.distanceRatio, y = calculateY(cannonY, self.game), onComplete = self.listener})
			transition.to(self.background, {time = 100, x = calculateX(cannonX, self.game) * self.background.distanceRatio, y = calculateY(cannonY, self.game), onComplete = self.listener})
			self.game.cameraState = "FOCUSING"
		end		
	elseif (self.game.cameraState == "CANNONBALL_FOCUS") then
		if (self.game.bullet ~= nil and self.game.bullet:isAlive()) then
--            print("Camera coords")
--            print(self.game.bullet:getX())
--            print(self.game.bullet:getY())
			self.world.x = calculateX(self.game.bullet:getX(), self.game)
			self.world.y = calculateY(self.game.bullet:getY(), self.game)
			self.sky.x = calculateX(self.game.bullet:getX(), self.game) * self.sky.distanceRatio
			self.sky.y = calculateY(self.game.bullet:getY(), self.game)
			self.background.x = calculateX(self.game.bullet:getX(), self.game) * self.background.distanceRatio
			self.background.y = calculateY(self.game.bullet:getY(), self.game)
		end
	elseif (self.game.cameraState == "FOCUSING") then
		-- do nothing
	end
end
