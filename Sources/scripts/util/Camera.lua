module(..., package.seeall)

Camera = {game = nil, world = nil, sky = nil, background = nil}

-- Constructor
-- Requires object with game, world and display parametres
--todo: refactor code duplication
function Camera:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self

	-- camera pad to detect dragging worl by finger
	-- todo ilya pimenov : refactor constants
	o.cameraPad = display.newRect(0, 0, 1000, 600)
	o.cameraPad:setFillColor(0, 0, 0, 0)
	o.world:insert(o.cameraPad)
	o.listener = o.cameraPad:addEventListener("touch", o)

	o.name = "camera"
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
		return display.screenOriginY
	elseif (desiredY - display.screenOriginY > game.worldHeight - 3 * display.contentHeight / 4) then
		return  - display.screenOriginY - (game.worldHeight - display.contentHeight)
    else
		return - desiredY + display.contentHeight / 4
	end	
end

function Camera:touch(event)
    if event.phase == "began" then
    	display.getCurrentStage():setFocus(event.source)
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
	        if (self.world.x - self.xDelta > 0 or self.world.x - self.xDelta < display.contentWidth - self.game.worldWidth) then
	        	self.xDelta = 0
	        end
	        if (self.world.y - self.yDelta > 0 or self.world.y - self.yDelta < display.contentHeight - self.game.worldHeight) then
	        	self.yDelta = 0
	        end

			self.world.x = self.world.x - self.xDelta		
			self.world.y = self.world.y - self.yDelta
			self.sky.x = self.sky.x - self.xDelta * self.sky.distanceRatio
			self.sky.y = self.sky.y - self.yDelta * self.sky.distanceRatio
			self.background.x = self.background.x - self.xDelta * self.background.distanceRatio
			self.background.y = self.background.y - self.yDelta * self.background.distanceRatio			

			-- if we had a timer to go back we should cancel it
			if (self.cameraBackTimer ~= nil) then
				timer.cancel(self.cameraBackTimer)
				self.cameraBackTimer = nil
			end

	    elseif event.phase == "ended" or event.phase == "cancelled" then
	    	self.cameraBackTimer = timer.performWithDelay( self.game.cameraGoBackDelay, function (event)
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
