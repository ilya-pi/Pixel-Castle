-- 320 x 480
-- true 320 x 568

-- hide status bar
display.setStatusBar(display.HiddenStatusBar)

local widget = require("widget")

physics = require("physics")
physics.start()
physics.setGravity(0, 9.8)

local game_module = require("scripts.GameModel")
local sky_module = require("scripts.SkyViewController")
local earth_module = require("scripts.EarthViewController")
local camera_module = require("scripts.util.Camera")
local controls_module = require("scripts.Controls")
local wind_module = require("scripts.Wind")

local game = game_module.GameModel:new()
local splash = require("scripts.splash")
local world = display.newGroup()

local controls1
local controls2
local wind = wind_module.Wind:new({x = 10, y = 10})

local function createCannonBallPixel(x, y)
	local result = display.newRect(x, y, game.pixel, game.pixel)
	result.myName = "cannonball"
	result.strokeWidth = 1
	result:setFillColor(26, 55, 37)
	result:setStrokeColor(26, 55, 37)
	physics.addBody(result, {density = 100, friction = 0, bounce = 0})
	result.isBullet = true
	return result
end

local function fireBullet(x, y, dx, dy)
	local cbp1 = createCannonBallPixel(x, y)
	local cbp2 = createCannonBallPixel(x + game.pixel, y)
	local cbp3 = createCannonBallPixel(x, y + game.pixel)
	local cbp4 = createCannonBallPixel(x + game.pixel, y + game.pixel)	
	world:insert(cbp1)
	world:insert(cbp2)
	world:insert(cbp3)		
	world:insert(cbp4)
	local joint1 = physics.newJoint( "weld", cbp1, cbp2, x + game.pixel, y + game.pixel)
	local joint2 = physics.newJoint( "weld", cbp2, cbp3, x + game.pixel, y + game.pixel)
	local joint3 = physics.newJoint( "weld", cbp3, cbp4, x + game.pixel, y + game.pixel)
	local joint4 = physics.newJoint( "weld", cbp4, cbp1, x + game.pixel, y + game.pixel)	
	cbp1:applyForce(dx * 750, - dy * 750, x, y)
	cbp2:applyForce(dx * 750, - dy * 750, x + game.pixel, y + game.pixel)
	cbp3:applyForce(dx * 750, - dy * 750, x + game.pixel, y + game.pixel)
	cbp4:applyForce(dx * 750, - dy * 750, x + game.pixel, y + game.pixel)
	return cbp1
end

local function onCollision(event)
   if (event.object1.myName == "brick" or event.object2.myName == "brick") then
   		event.object1.state = "removed"
   		event.object2.state = "removed"
   		event.object1:removeSelf()
   		event.object2:removeSelf()
   end
end

-- Main game loop
local function gameLoop()

	if (game.bullet ~= nil and game.bullet.x ~= nil and game.bullet.y ~= nil) then
		if (game.bullet.x > game.worldWidth or game.bullet.x < 0 or game.bullet.y > game.worldHeight) then
			game.bullet = nil
			-- todo remove the bullet object itself
		end
    end

    if (game.state.name == "P1") then
        controls1:render(30, 200)
    elseif (game.state.name == "BULLET") then
        --todo: camera:update(bullet.x, bullet.y)
    elseif (game.state.name == "MOVE_TO_P2") then
        --nothing
    elseif (game.state.name == "P2") then
        controls2:render(300, 200)
    elseif (game.state.name == "MOVE_TO_P1") then
        --nothing

	-- camera interactions
	if (game.bullet == nil or game.bullet.x == nil or game.bullet.y == nil) then
		if (game.state == "PLAYER1") then
			game.cameraState = "CASTLE1_FOCUS"
            controls2:hide()
            controls1:show()
            controls1:render(30, 200)
		elseif (game.state == "PLAYER2") then
			game.cameraState = "CASTLE2_FOCUS"
            controls1:hide()
            controls2:show()
            controls2:render(300, 200)
		end
	end
end

local impulse = 11

local fireButtonPress = function(event)
    if (event.phase == "ended") then
        if (game.state == "PLAYER1") then
            local cannonX = (game.castle1xOffset + game.castleWidth / 2) * game.pixel
            local cannonY =  game.worldHeight - (game.castle1.yLevel + game.castleHeight + game.cannonYOffset) * game.castleHeight
            game.bullet = fireBullet(cannonX, cannonY, impulse * math.sin(math.rad(controls1:getAngle())), impulse * math.cos(math.rad(controls1:getAngle()))) --todo refactor
            game.cameraState = "CANNONBALL_FOCUS"
            game.state = "PLAYER2"
            -- todo remove code duplication here!
            if game.castle2:isDestroyed(game) then
                game.state = "PLAYER2_LOST"
                -- todo refactor
                local t = display.newText("Player 2 Lost", 0, 0, "AmericanTypewriter-Bold", 42)
                t.x, t.y = display.contentCenterX, display.contentCenterY
                t:setTextColor(255, 0, 0)
            end
        elseif (game.state == "PLAYER2") then
            local cannonX = (game.castle2xOffset + game.castleWidth / 2) * game.pixel
            local cannonY =  game.worldHeight - (game.castle2.yLevel + game.castleHeight + game.cannonYOffset) * game.castleHeight
            game.bullet = fireBullet(cannonX, cannonY, impulse * math.sin(math.rad(controls2:getAngle())), impulse * math.cos(math.rad(controls2:getAngle()))) --todo refactor
            game.cameraState = "CANNONBALL_FOCUS"
            game.state = "PLAYER1"
            -- todo remove code duplication here! and here!
            if game.castle1:isDestroyed(game) then
                game.state = "PLAYER1_LOST"
                -- todo refactor
                local t = display.newText("Player 1 Lost", 0, 0, "AmericanTypewriter-Bold", 42)
                t.x, t.y = display.contentCenterX, display.contentCenterY
                t:setTextColor(255, 0, 0)
            end
        end
    end
end

local fireButtonRelease = function(event)
end

local function cameraListener()
    print("move complete!")
end

local function eventPlayer1Fire()
    controls1:hide()
    --todo: fireBullet() -> on remove listener(game:nextState)
end

local function eventPlayer2Fire()
    controls2:hide()
    --todo: fireBullet() -> on remove listener(game:nextState)
end

local function eventBulletRemoved()
    --move camera to next player
    --todo: camera:moveTo(x, y) -> listener(game:nextState())
end

local function eventPlayer1Active()
    wind:update()
    controls1:show()
    --todo: button.push -> listener(game:nextState)
end

local function eventPlayer2Active()
    wind:update()
    controls2:show()
    random_carma(castle)
    --todo: button.push -> listener(game:nextState)
end


local function startGame()
     splash.dismissSplashScreen()

     game:addState({"P1", player1Fire})
     game:addState({"BULLET", bulletRemoved})
     game:addState({"MOVE_TO_P2", player2Active})
     game:addState({"P2", player2Fire})
     game:addState({"MOVE_TO_P1", player1Active})

     local camera = camera_module.Camera:new({game = game, world = world, display = display, listener = cameraListener})

     --todo insert ground later
     -- ground
	-- local ground = display.newRect(0, h, w, 10);
	-- ground:setFillColor(26, 55, 37)
	-- ground:setStrokeColor(26, 55, 37)

	-- world:insert(ground)
	-- physics.addBody(ground, "static")

	local sky = sky_module.SkyViewController:new()
	sky:render(physics, world, game)

	local earth = earth_module.EarthViewController:new()
	earth:render(physics, world, game)

    controls1 = controls_module.Controls:new({angle = 45, x = 30, y = 200})
    controls2 = controls_module.Controls:new({angle = -45, x = 300, y = 200})
    controls1.button:addEventListener("touch", game:nextState())
    controls2.button:addEventListener("touch", game:nextState())

	Runtime:addEventListener("collision", onCollision)
	Runtime:addEventListener( "enterFrame",
		function ()
			camera:moveCamera()
        end
    )

	timer.performWithDelay(game.delay, gameLoop, 0)
end

splash.splashScreen()
-- splash.fullSplash:addEventListener("tap", startGame)
startGame()
