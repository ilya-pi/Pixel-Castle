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

local game = game_module.GameModel:new()

-- Load external Splash Screen
local splash = require("scripts.splash")

local bricksTable = {}
local xOffset = 100
local yGround = 480
local delay = 200
local brickSize = 10

local w = display.contentWidth
local h = display.contentHeight

local state
local shotStrenth = 0
local shotTimeout = 0

-- Initialising scene

local world = display.newGroup()

local fireButtonPress = function( event )
	state = "FIRE_PRESSED"
end

local fireButtonRelease = function( event )
	state = "FIRE_RELEASED"
end

--todo
--up button
--down button

local function constructCastle(x)
	for i=0,9 do
		for l=0,9 do
			local current = i * 10 + l;
			bricksTable[current] = display.newRect(x  + l * brickSize, h - i * brickSize, brickSize , brickSize)
			world:insert(bricksTable[current])
			bricksTable[current].myName = "brick"
			bricksTable[current].strokeWidth = 1
			bricksTable[current]:setFillColor(26, 55, 37)
			bricksTable[current]:setStrokeColor(26, 55, 37)

			physics.addBody(bricksTable[current], "static")
		end
	end
end

local function createCannonBallPixel(x, y)
	local result = display.newRect(x, y, brickSize, brickSize)
	result.myName = "cannonball"
	-- result.rotation = math.random(90)
	result.strokeWidth = 1
	result:setFillColor(26, 55, 37)
	result:setStrokeColor(26, 55, 37)
	physics.addBody(result, {density = 100, friction = 0, bounce = 0})
	result.isBullet = true
	return result
end

local function swapCannonBall(event)
	local cbp1 = createCannonBallPixel(event.x, event.y)
	local cbp2 = createCannonBallPixel(event.x + brickSize, event.y)
	local cbp3 = createCannonBallPixel(event.x, event.y + brickSize)
	local cbp4 = createCannonBallPixel(event.x + brickSize, event.y + brickSize)	
	local joint1 = physics.newJoint( "weld", cbp1, cbp2, event.x + brickSize, event.y + brickSize)
	local joint2 = physics.newJoint( "weld", cbp2, cbp3, event.x + brickSize, event.y + brickSize)
	local joint3 = physics.newJoint( "weld", cbp3, cbp4, event.x + brickSize, event.y + brickSize)
	local joint4 = physics.newJoint( "weld", cbp4, cbp1, event.x + brickSize, event.y + brickSize)	
end

local function fireBullet(x, y, dx, dy)
	local cbp1 = createCannonBallPixel(x, y)
	local cbp2 = createCannonBallPixel(x + brickSize, y)
	local cbp3 = createCannonBallPixel(x, y + brickSize)
	local cbp4 = createCannonBallPixel(x + brickSize, y + brickSize)	
	world:insert(cbp1)
	world:insert(cbp2)
	world:insert(cbp3)		
	world:insert(cbp4)
	local joint1 = physics.newJoint( "weld", cbp1, cbp2, x + brickSize, y + brickSize)
	local joint2 = physics.newJoint( "weld", cbp2, cbp3, x + brickSize, y + brickSize)
	local joint3 = physics.newJoint( "weld", cbp3, cbp4, x + brickSize, y + brickSize)
	local joint4 = physics.newJoint( "weld", cbp4, cbp1, x + brickSize, y + brickSize)	
	cbp1:applyForce(dx * 750, - dy * 750, x, y)
	cbp2:applyForce(dx * 750, - dy * 750, x + game.pixel, y + game.pixel)
	cbp3:applyForce(dx * 750, - dy * 750, x + game.pixel, y + game.pixel)
	cbp4:applyForce(dx * 750, - dy * 750, x + game.pixel, y + game.pixel)
	return cbp1
end

local function onCollision(event)
   if (event.object1.myName == "brick" or event.object2.myName == "brick") then
   		event.object1:removeSelf()
   		event.object2:removeSelf()
   end
end

local oldX = 0
local currentBullet = nil

-- Camera follows bolder automatically
local function moveCamera()	
	if (state == "FIRED" and currentBullet.x ~= nil and currentBullet.x > 80 and currentBullet.x < 1100) then
		world.x = -currentBullet.x + 80
	elseif (state == "FIRED" and shotTimeout > 1700) then
		shotTimeout = 0
		transition.to(world, {time = 100, x = 0})
		state = nil
	end

	-- if (game.cameraState == "CANNONBALL_FOCUS")
end

-- UI
local t = display.newText( "...", 0, 0, "AmericanTypewriter-Bold", 18 )
t.x, t.y = display.contentCenterX, display.contentCenterX / 5
t.alpha = 0

local function showUi()
	t.alpha = 1
end

-- Main game loop
local function gameLoop()
	if (state == "FIRE_PRESSED") then
		shotStrenth = shotStrenth + 1
		t.text = shotStrenth
		if (shotStrenth >= 27) then
			state = "FIRE_RELEASED"
		end
	elseif (state == "FIRE_RELEASED") then
		t.text = "fire !!!"
		--todo actually call fire method
		-- currentBullet = fireBullet(15, h - 15, shotStrenth, shotStrenth)
		if (game.state == "PLAYER1") then
			local cannonX = (game.castle1xOffset + game.castleWidth / 2) * game.pixel
			local cannonY =  game.worldHeight - (game.castle1.yLevel + game.castleHeight + game.cannonYOffset) * game.castleHeight
			currentBullet = fireBullet(cannonX, cannonY, 6, 6)
		end

		-- currentBullet = fireBullet(15, h - 15, 9, 9)
		state = "FIRED"
		shotStrenth = 0
	elseif (state == "FIRED") then
		shotTimeout = shotTimeout + delay
	end
end

function startGame()
     splash.dismissSplashScreen()

     -- ground
	local ground = display.newRect(0, h, w, 10);
	ground:setFillColor(26, 55, 37)
	ground:setStrokeColor(26, 55, 37)
	world:insert(ground)
	physics.addBody(ground, "static")

	local sky = sky_module.SkyViewController:new()
	sky:render(physics, world, game)

	local earth = earth_module.EarthViewController:new()
	earth:render(physics, world, game)

	-- constructCastle(2 * w / 3)

	local fireButton = widget.newButton{
		default = "images/fireButton.png",
		over = "images/fireButtonHover.png",
		onPress = fireButtonPress,
		onRelease = fireButtonRelease,
		label = "FIRE",
		emboss = true,
	}

	fireButton.x, fireButton.y = w - fireButton.width / 2, h - fireButton.height / 2

	Runtime:addEventListener("collision", onCollision)
	Runtime:addEventListener( "enterFrame", moveCamera)

	showUi()

	timer.performWithDelay(delay, gameLoop, 0)
end

splash.splashScreen()
-- splash.fullSplash:addEventListener("tap", startGame)
startGame()
