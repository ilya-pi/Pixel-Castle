module(..., package.seeall)


--todo: bunch of optimizations needed, to avoid creating local variables in loop for ex
local Memmory = require("scripts.util.Memmory")
local calculatedX
local calculatedY
local focusOnCastleTime = 200
local initialRatio = 1

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

    o.ratio = initialRatio
    local minScaleFactor = tonumber(game.levelConfig.screens[1].levels[game.selectedLevel].minScaleFactor)
    if minScaleFactor == -1 then
        o.minRatio = screenWidth / (game.levelWidth * game.pixel)
    else 
        o.minRatio = minScaleFactor
    end
    --o.minRatio = 0.5

    game.sky.x = display.screenOriginX
    game.sky.y = -(game.levelHeight * game.pixel - screenHeight) + display.screenOriginY
    game.sky.xScale = o.ratio
    game.sky.yScale = o.ratio

    game.background.x = display.screenOriginX
    game.background.y = -(game.levelHeight * game.pixel - screenHeight) + display.screenOriginY
    game.sky.xScale = o.ratio
    game.sky.yScale = o.ratio

    game.world.x = display.screenOriginX
    game.world.y = -(game.levelHeight * game.pixel - screenHeight) + display.screenOriginY
    game.sky.xScale = o.ratio
    game.sky.yScale = o.ratio

    return o
end


local function calculateTouchX(desiredX, ratio)
    --print("x " .. game.world.x .. " xReference " .. game.world.xReference .. " xOrigin " .. game.world.xOrigin .. " desired " .. desiredX .. " origin " .. display.screenOriginX)
    if (desiredX >= display.screenOriginX) then --left border
        return display.screenOriginX, display.screenOriginX, display.screenOriginX
    else
        local rightBorder = -(game.levelWidth * game.pixel * ratio - screenWidth) + display.screenOriginX
        if (desiredX <= rightBorder) then --right border
            return rightBorder ,
            ((rightBorder - display.screenOriginX) * game.background.distanceRatio + display.screenOriginX),
            ((rightBorder - display.screenOriginX) * game.sky.distanceRatio + display.screenOriginX)
        end
        --final x calculation the same for rightBorder and for usual case
    end
    return desiredX ,
    ((desiredX - display.screenOriginX) * game.background.distanceRatio + display.screenOriginX),
    ((desiredX - display.screenOriginX) * game.sky.distanceRatio + display.screenOriginX)
end

local function calculateTouchY(desiredY, ratio)
    -- local topBorder = -(game.levelHeight * game.pixel * ratio - screenHeight - display.screenOriginY)
--     return topBorder, topBorder, topBorder
    if (desiredY >= display.screenOriginY) then
        --print("case1 " .. display.screenOriginY)
        return 2 * display.screenOriginY, 2 * display.screenOriginY, 2 * display.screenOriginY
    else
        local topBorder = -(game.levelHeight * game.pixel * ratio - screenHeight - 2 * display.screenOriginY)
        if (desiredY <= topBorder) then
            --print("case2 " .. topBorder)
            return topBorder, topBorder, topBorder
        end
    end
    --print("case3 " .. desiredY)
    return desiredY, desiredY, desiredY
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

            local worldX, backgroundX, skyX = calculateTouchX(game.world.x - self.xDelta, self.ratio)
            local worldY, backgroundY, skyY = calculateTouchY(game.world.y - self.yDelta, self.ratio)

			game.world.x = worldX
			game.world.y = worldY
			game.sky.x = skyX
			game.sky.y = skyY
			game.background.x = backgroundX
			game.background.y = backgroundY

			-- if we had a timer to go back we should cancel it
			if (Memmory.timerStash.cameraComebackTimer ~= nil) then
				timer.cancel(Memmory.timerStash.cameraComebackTimer)
				Memmory.timerStash.cameraComebackTimer = nil
			end

	    elseif event.phase == "ended" or event.phase == "cancelled" then
	    	-- Memmory.timerStash.cameraComebackTimer = timer.performWithDelay( game.cameraGoBackDelay, function (event)
	    	-- 		if (game.state.name == "P1") then
	    	-- 			game.cameraState = "CASTLE1_FOCUS"
	    	-- 		elseif (game.state.name == "P2") then
	    	-- 			game.cameraState = "CASTLE2_FOCUS"
	    	-- 		end
	    	-- 	end);
	    	display.getCurrentStage():setFocus( nil )
			self.isFocus = nil
	    end
	end
    return true
end

-- Camera follows bolder automatically
function Camera:moveCamera()
    if game.state.name == "PAUSEMENU" then
        return
    end

    --todo: a lot of possible optimisations here for ex. do not call calculateX,Y three times per call
    --todo: get castle as a parameter
	if (game.cameraState == "CASTLE1_FOCUS") then
        self.ratio = initialRatio

        if (game.castle1 ~= nil) then
			local cannonX = -game.castle1:cannonX() * self.ratio + game.castle1.width + 45
			local cannonY = -game.castle1:cannonY() * self.ratio + (display.contentHeight - game.castle1.height) - 25
			Memmory.transitionStash.cameraWorldTransition = transition.to(game.world,
                {
                    time = focusOnCastleTime,
                    x = calculateTouchX(cannonX, self.ratio),
                    y = calculateTouchY(cannonY, self.ratio),
                    xScale = initialRatio,
                    yScale = initialRatio,
                    onComplete = self.listener
                }
            )
			Memmory.transitionStash.cameraSkyTransition = transition.to(game.sky,
                {
                    time = focusOnCastleTime,
                    x = (calculateTouchX(cannonX, self.ratio) - display.screenOriginX) * game.sky.distanceRatio + display.screenOriginX,
                    y = calculateTouchY(cannonY, self.ratio),
                    xScale = initialRatio,
                    yScale = initialRatio,
                    onComplete = self.listener
                }
            )
			Memmory.transitionStash.cameraBgTransition = transition.to(game.background,
                {
                    time = focusOnCastleTime,
                    x = (calculateTouchX(cannonX, self.ratio) - display.screenOriginX) * game.background.distanceRatio + display.screenOriginX,
                    y = calculateTouchY(cannonY, self.ratio),
                    xScale = initialRatio,
                    yScale = initialRatio,
                    onComplete = self.listener
                }
            )
			game.cameraState = "FOCUSING"
		end	
	elseif (game.cameraState == "CASTLE2_FOCUS") then
        self.ratio = initialRatio
		if (game.castle2 ~= nil) then
            local cannonX = -game.castle2:cannonX() * self.ratio + (display.contentWidth - game.castle2.width) - 45
            local cannonY = -game.castle2:cannonY() * self.ratio + (display.contentHeight - game.castle2.height) - 25
			Memmory.transitionStash.cameraWorldTransition = transition.to(game.world,
                {
                    time = focusOnCastleTime,
                    x = calculateTouchX(cannonX, self.ratio),
                    y = calculateTouchY(cannonY, self.ratio),
                    xScale = initialRatio,
                    yScale = initialRatio,
                    onComplete = self.listener
                }
            )
			Memmory.transitionStash.cameraSkyTransition = transition.to(game.sky,
                {
                    time = focusOnCastleTime,
                    x = (calculateTouchX(cannonX, self.ratio) - display.screenOriginX) * game.sky.distanceRatio + display.screenOriginX,
                    y = calculateTouchY(cannonY, self.ratio),
                    xScale = initialRatio,
                    yScale = initialRatio,
                    onComplete = self.listener
                }
            )
			Memmory.transitionStash.cameraBgTransition = transition.to(game.background,
                {
                    time = focusOnCastleTime,
                    x = (calculateTouchX(cannonX, self.ratio) - display.screenOriginX) * game.background.distanceRatio + display.screenOriginX,
                    y = calculateTouchY(cannonY, self.ratio),
                    xScale = initialRatio,
                    yScale = initialRatio,
                    onComplete = self.listener
                }
            )
			game.cameraState = "FOCUSING"
		end		
	elseif (game.cameraState == "CANNONBALL_FOCUS") then
		if (game.bullet ~= nil and game.bullet:isAlive()) then


            local viewPortHeight
            if -game.bullet:getY() >= display.screenOriginY then
                viewPortHeight = game.levelHeight * game.pixel - display.screenOriginY
            else
                viewPortHeight = game.levelHeight * game.pixel - game.bullet:getY() - display.screenOriginY
            end
            -- local viewPortHeight = game.levelHeight * game.pixel - game.bullet:getY() - display.screenOriginY

            if viewPortHeight < display.contentHeight - display.screenOriginY then
                viewPortHeight = display.contentHeight - display.screenOriginY
            end
            self.ratio = screenHeight / viewPortHeight
            if self.ratio < self.minRatio then self.ratio = self.minRatio end

            local bulletMargin
            if game.state.name == "BULLET1" then
                bulletMargin = -display.screenOriginX - 100 --todo bullet at the center !!! delete only after #95 is closed
            else
                bulletMargin = -screenWidth - display.screenOriginX + 100 --todo bullet at the center !!! delete only after #95 is closed
            end

            local worldX, backgroundX, skyX = calculateTouchX(-game.bullet:getX() * self.ratio - bulletMargin, self.ratio)  --todo: Sergey Belyakov get rid of jumps when shooting
            local worldY, backgroundY, skyY = calculateTouchY(-game.bullet:getY() * self.ratio + 100, self.ratio)
            --            print("VP " .. viewPortHeight .. "; bullet x=" .. -game.bullet:getX() .. ", y=" .. -game.bullet:getY() .. "; bottom " .. -(game.levelHeight * game.pixel * self.ratio - screenHeight - display.screenOriginY))

			game.world.x = worldX
			game.world.y = worldY
            game.world.xScale = self.ratio --todo: does the scale factor affects on physics!?
            game.world.yScale = self.ratio --todo: does the scale factor affects on physics!?

            game.sky.x = skyX
			game.sky.y = skyY
            game.sky.xScale = self.ratio
            game.sky.yScale = self.ratio

            game.background.x = backgroundX
			game.background.y = backgroundY
            game.background.xScale = self.ratio
            game.background.yScale = self.ratio

        end
	elseif (game.cameraState == "FOCUSING") then
		-- do nothing
    elseif game.cameraState == "OVERVIEW" then

        self.ratio = (-2 * display.screenOriginX + display.contentWidth) / (game.levelWidth * game.pixel)

        local properY = display.screenOriginY - (game.levelHeight * game.pixel * self.ratio - (display.contentHeight - 2 * display.screenOriginY))
        game.world.x, game.world.y = display.screenOriginX, properY

        game.world.xScale = self.ratio
        game.world.yScale = self.ratio

        game.sky.x, game.sky.y = display.screenOriginX, properY
        game.sky.xScale = self.ratio
        game.sky.yScale = self.ratio

        local bgSubstitution = display.newRect(
            game.sky, 
            0,  -- because the group itself is already at display.screenOriginX
            display.screenOriginY / self.ratio - properY / self.ratio,  -- because sky is at properY position
            (-2 * display.screenOriginX + display.contentWidth) / self.ratio, (properY - display.screenOriginY) / self.ratio)
        bgSubstitution:setFillColor(game.SKY_SUBSTITUTION_COLOR.r, game.SKY_SUBSTITUTION_COLOR.g, game.SKY_SUBSTITUTION_COLOR.b)

        game.background.x, game.background.y = display.screenOriginX, properY
        game.background.xScale = self.ratio
        game.background.yScale = self.ratio
    end
end
