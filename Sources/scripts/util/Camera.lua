module(..., package.seeall)

local Memmory = require("scripts.util.Memmory")
local calculatedX
local calculatedY

Camera = {}

-- Constructor
-- Requires object with game, world and display parametres
--todo: refactor code duplication
function Camera:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self

	-- camera pad to detect dragging worl by finger
	-- todo ilya pimenov : refactor constants
	o.cameraPad = display.newRect(0, 0, game.levelWidth * game.pixel, game.levelHeight * game.pixel)
    o.cameraPad:setReferencePoint(display.TopLeftReferencePoint)
    o.cameraPad:setFillColor(0, 0, 0, 0)
    game.world:insert(o.cameraPad)
    o.cameraPad.x = 0
    o.cameraPad.y = 0

    o.listener = o.cameraPad:addEventListener("touch", o)
	o.name = "camera"

    o.xLeftLimit = display.screenOriginX
    o.xRightLimit = - (game.levelWidth * game.pixel - (display.contentWidth - display.screenOriginX))
    o.yBottomLimit = -(game.levelHeight * game.pixel - (display.contentHeight - display.screenOriginY))
    o.yTopLimit = display.screenOriginY

    --game.sky:setReferencePoint(display.TopLeftReferencePoint)
    game.sky.x = display.screenOriginX
    game.sky.y = - (game.levelHeight * game.pixel - screenHeight) + display.screenOriginY

    --game.background:setReferencePoint(display.TopLeftReferencePoint)
    game.background.x = display.screenOriginX
    game.background.y = - (game.levelHeight * game.pixel - screenHeight) + display.screenOriginY

    --game.world:setReferencePoint(display.TopLeftReferencePoint)
    game.world.x = display.screenOriginX
    game.world.y = - (game.levelHeight * game.pixel - screenHeight) + display.screenOriginY

    return o
end




local function calculateTouchX(desiredX)
    --print("desired " .. desiredX .. "; left " .. display.screenOriginX .. "; right " .. -(game.levelWidth * game.pixel - screenWidth) + display.screenOriginX)
    if (desiredX >= display.screenOriginX) then
        return display.screenOriginX
    elseif (desiredX <= -(game.levelWidth * game.pixel - screenWidth) + display.screenOriginX) then --todo: move calculations into initialization because it's a constant for every level
        return -(game.levelWidth * game.pixel - screenWidth) + display.screenOriginX
    else
        return desiredX
    end
end

local function calculateTouchY(desiredY)
    if (desiredY >= display.screenOriginY) then
        return display.screenOriginY
    elseif (desiredY <= -(game.levelHeight * game.pixel - screenHeight - display.screenOriginY)) then --todo: move calculations into initialization because it's a constant for every level
        return -(game.levelHeight * game.pixel - screenHeight - display.screenOriginY)
    else
        return desiredY
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

            self.calculatedX = calculateTouchX(game.world.x - self.xDelta)
            self.calculatedY = calculateTouchY(game.world.y - self.yDelta)

			game.world.x = self.calculatedX
			game.world.y = self.calculatedY
			game.sky.x = (self.calculatedX - display.screenOriginX) * game.sky.distanceRatio + display.screenOriginX
			game.sky.y = self.calculatedY
			game.background.x = (self.calculatedX - display.screenOriginX) * game.background.distanceRatio + display.screenOriginX
			game.background.y = self.calculatedY

			-- if we had a timer to go back we should cancel it
			if (Memmory.timerStash.cameraComebackTimer ~= nil) then
				timer.cancel(Memmory.timerStash.cameraComebackTimer)
				Memmory.timerStash.cameraComebackTimer = nil
			end

	    elseif event.phase == "ended" or event.phase == "cancelled" then
	    	Memmory.timerStash.cameraComebackTimer = timer.performWithDelay( game.cameraGoBackDelay, function (event)
	    			if (game.state.name == "P1") then
	    				game.cameraState = "CASTLE1_FOCUS"
	    			elseif (game.state.name == "P2") then
	    				game.cameraState = "CASTLE2_FOCUS"
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
    --todo: a lot of possible optimisations here for ex. do not call calculateX,Y three times per call
    --todo: get castle as a parameter
	if (game.cameraState == "CASTLE1_FOCUS") then
        game.world.xScale = 1
        game.world.yScale = 1
        game.sky.xScale = 1
        game.sky.yScale = 1
        game.background.xScale = 1
        game.background.yScale = 1

        if (game.castle1 ~= nil) then
			local cannonX = -game.castle1:cannonX()
			local cannonY =  -game.castle1:cannonY()
			Memmory.transitionStash.cameraWorldTransition = transition.to(game.world, {time = 100, x = calculateTouchX(cannonX + 100), y = calculateTouchY(cannonY), onComplete = self.listener})
			Memmory.transitionStash.cameraSkyTransition = transition.to(game.sky,
                {
                    time = 100,
                    x = (calculateTouchX(cannonX + 100) - display.screenOriginX) * game.sky.distanceRatio + display.screenOriginX,
                    y = calculateTouchY(cannonY),
                    onComplete = self.listener
                }
            )
			Memmory.transitionStash.cameraBgTransition = transition.to(game.background,
                {
                    time = 100,
                    x = (calculateTouchX(cannonX + 100) - display.screenOriginX) * game.background.distanceRatio + display.screenOriginX,
                    y = calculateTouchY(cannonY),
                    onComplete = self.listener
                }
            )
			game.cameraState = "FOCUSING"
		end	
	elseif (game.cameraState == "CASTLE2_FOCUS") then
        game.world.xScale = 1
        game.world.yScale = 1
        game.sky.xScale = 1
        game.sky.yScale = 1
        game.background.xScale = 1
        game.background.yScale = 1
		if (game.castle2 ~= nil) then
			local cannonX = -game.castle2:cannonX()
			local cannonY =  -game.castle2:cannonY()
			Memmory.transitionStash.cameraWorldTransition = transition.to(game.world, {time = 100, x = calculateTouchX(cannonX), y = calculateTouchY(cannonY), onComplete = self.listener})
			Memmory.transitionStash.cameraSkyTransition = transition.to(game.sky,
                {
                    time = 100,
                    x = (calculateTouchX(cannonX) - display.screenOriginX) * game.sky.distanceRatio + display.screenOriginX,
                    y = calculateTouchY(cannonY),
                    onComplete = self.listener
                }
            )
			Memmory.transitionStash.cameraBgTransition = transition.to(game.background,
                {
                    time = 100,
                    x = (calculateTouchX(cannonX) - display.screenOriginX) * game.background.distanceRatio + display.screenOriginX,
                    y = calculateTouchY(cannonY),
                    onComplete = self.listener
                }
            )
			game.cameraState = "FOCUSING"
		end		
	elseif (game.cameraState == "CANNONBALL_FOCUS") then
		if (game.bullet ~= nil and game.bullet:isAlive()) then
            if game.state.name == "BULLET1" then
                calculatedX = calculateTouchX(-(game.bullet:getX() - 100))  --todo: Sergey Belyakov get rid of jumps when shooting
            else
                calculatedX = calculateTouchX(-(game.bullet:getX() - screenWidth + 100)) --todo: Sergey Belyakov get rid of jumps when shooting
            end
            calculatedY = calculateTouchY(-game.bullet:getY() + 30)


            local viewPortHeight = game.levelHeight * game.pixel - game.bullet:getY() - display.screenOriginY
            if viewPortHeight < display.contentHeight - display.screenOriginY then
                viewPortHeight = display.contentHeight - display.screenOriginY
            end
            --print(viewPortHeight)

            local ratio = screenHeight / viewPortHeight

			game.world.x = calculatedX * ratio
			game.world.y = calculatedY * ratio
            game.world.xScale = ratio
            game.world.yScale = ratio

            game.sky.x = ((calculatedX - display.screenOriginX) * game.sky.distanceRatio + display.screenOriginX) * ratio
			game.sky.y = calculatedY * ratio
            game.sky.xScale = ratio
            game.sky.yScale = ratio

            game.background.x = ((calculatedX - display.screenOriginX) * game.background.distanceRatio + display.screenOriginX) * ratio
			game.background.y = calculatedY * ratio
            game.background.xScale = ratio
            game.background.yScale = ratio

        end
	elseif (game.cameraState == "FOCUSING") then
		-- do nothing
    end
end
