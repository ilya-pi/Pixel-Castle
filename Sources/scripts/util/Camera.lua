module(..., package.seeall)

local Memmory = require("scripts.util.Memmory")

Camera = {game = nil}

-- Constructor
-- Requires object with game, world and display parametres
--todo: refactor code duplication
function Camera:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self

	-- camera pad to detect dragging worl by finger
	-- todo ilya pimenov : refactor constants
	o.cameraPad = display.newRect(0, 0, o.game.level_map.level.width * o.game.pixel, o.game.level_map.level.height * o.game.pixel)
	o.cameraPad:setFillColor(0, 0, 0, 0)
	o.game.world:insert(o.cameraPad)
	o.listener = o.cameraPad:addEventListener("touch", o)

	o.name = "camera"
	return o
end

local function calculateX(desiredX, game)
	if (desiredX + display.screenOriginX < display.contentWidth / 2) then
		return display.screenOriginX
	elseif (desiredX - display.screenOriginX > game.level_map.level.width * game.pixel - display.contentWidth / 2) then
		return - display.screenOriginX - (game.level_map.level.width * game.pixel - display.contentWidth)
	else
		return - desiredX + display.contentWidth / 2
	end
end

local function calculateY(desiredY, game)
	if (desiredY + display.screenOriginY < display.contentHeight / 4) then
		return display.screenOriginY
	elseif (desiredY - display.screenOriginY > game.level_map.level.height * game.pixel - 3 * display.contentHeight / 4) then
		return  - display.screenOriginY - (game.level_map.level.height * game.pixel - display.contentHeight)
    else
		return - desiredY + display.contentHeight / 4
	end	
end

function Camera:touch(event)
    if event.phase == "began" then
    	display.getCurrentStage():setFocus(event.target)
    	self.isFocus = true

        self.beginX = event.x
        self.beginY = event.y
    elseif self.isFocus then
	    if event.phase == "moved" and self.beginX ~= nil then        
	        self.xDelta = self.beginX - event.x
	        self.beginX = event.x
	        self.yDelta = self.beginY - event.y
	        self.beginY = event.y

	        -- Check for world limits
	        if (self.world.x - self.xDelta >= display.screenOriginX or self.world.x - self.xDelta <= display.contentWidth - display.screenOriginX - self.game.level_map.level.width * self.game.pixel) then
	        	self.xDelta = 0
	        end
	        if (self.world.y - self.yDelta >= display.screenOriginY or self.world.y - self.yDelta <= display.contentHeight - display.screenOriginY - self.game.level_map.level.height * self.game.pixel) then
	        	self.yDelta = 0
	        end

			self.game.world.x = self.game.world.x - self.xDelta		
			self.game.world.y = self.game.world.y - self.yDelta
			self.game.sky.x = self.game.sky.x - self.xDelta * self.game.sky.distanceRatio
			self.game.sky.y = self.game.sky.y - self.yDelta * self.game.sky.distanceRatio
			self.game.background.x = self.game.background.x - self.xDelta * self.game.background.distanceRatio
			self.game.background.y = self.game.background.y - self.yDelta * self.game.background.distanceRatio			

			-- if we had a timer to go back we should cancel it
			if (Memmory.timerStash.cameraComebackTimer ~= nil) then
				timer.cancel(Memmory.timerStash.cameraComebackTimer)
				Memmory.timerStash.cameraComebackTimer = nil
			end

	    elseif event.phase == "ended" or event.phase == "cancelled" then
	    	Memmory.timerStash.cameraComebackTimer = timer.performWithDelay( self.game.cameraGoBackDelay, function (event)
	    			if (self.game.state.name == "P1") then
	    				self.game.cameraState = "CASTLE1_FOCUS"
	    			elseif (self.game.state.name == "P2") then
	    				self.game.cameraState = "CASTLE2_FOCUS"
	    			end
	    		end);
	    	display.getCurrentStage():setFocus( nil )
			self.isFocus = nil
	    end
	end
    return true
end

-- Camera follows bolder automatically
function Camera:moveCamera()		
	if (self.game.cameraState == "CASTLE1_FOCUS") then		
		if (self.game.castle1 ~= nil) then
			local cannonX = self.game.castle1:cannonX()
			local cannonY =  self.game.castle1:cannonY()
			Memmory.transitionStash.cameraWorldTransition = transition.to(self.game.world, {time = 100, x = calculateX(cannonX, self.game), y = calculateY(cannonY, self.game), onComplete = self.listener})
			Memmory.transitionStash.cameraSkyTransition = transition.to(self.game.sky, {time = 100, x = calculateX(cannonX, self.game) * self.sky.distanceRatio, y = calculateY(cannonY, self.game), onComplete = self.listener})
			Memmory.transitionStash.cameraBgTransition = transition.to(self.game.background, {time = 100, x = calculateX(cannonX, self.game) * self.background.distanceRatio, y = calculateY(cannonY, self.game), onComplete = self.listener})
			self.game.cameraState = "FOCUSING"
		end	
	elseif (self.game.cameraState == "CASTLE2_FOCUS") then
		if (self.game.castle2 ~= nil) then
			local cannonX = self.game.castle2:cannonX()
			local cannonY =  self.game.castle2:cannonY()
			Memmory.transitionStash.cameraWorldTransition = transition.to(self.game.world, {time = 100, x = calculateX(cannonX, self.game), y = calculateY(cannonY, self.game), onComplete = self.listener})
			Memmory.transitionStash.cameraSkyTransition = transition.to(self.game.sky, {time = 100, x = calculateX(cannonX, self.game) * self.sky.distanceRatio, y = calculateY(cannonY, self.game), onComplete = self.listener})
			Memmory.transitionStash.cameraBgTransition = transition.to(self.game.background, {time = 100, x = calculateX(cannonX, self.game) * self.background.distanceRatio, y = calculateY(cannonY, self.game), onComplete = self.listener})
			self.game.cameraState = "FOCUSING"
		end		
	elseif (self.game.cameraState == "CANNONBALL_FOCUS") then
		if (self.game.bullet ~= nil and self.game.bullet:isAlive()) then
--            print("Camera coords")
--            print(self.game.bullet:getX())
--            print(self.game.bullet:getY())
			self.game.world.x = calculateX(self.game.bullet:getX(), self.game)
			self.game.world.y = calculateY(self.game.bullet:getY(), self.game)
			self.game.sky.x = calculateX(self.game.bullet:getX(), self.game) * self.sky.distanceRatio
			self.game.sky.y = calculateY(self.game.bullet:getY(), self.game)
			self.game.background.x = calculateX(self.game.bullet:getX(), self.game) * self.background.distanceRatio
			self.game.background.y = calculateY(self.game.bullet:getY(), self.game)
		end
	elseif (self.game.cameraState == "FOCUSING") then
		-- do nothing
	end
end
