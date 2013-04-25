-- hide status bar
display.setStatusBar(display.HiddenStatusBar)

physics = require("physics")
physics.start()
physics.setGravity(0, 9.8)

local game_module = require("scripts.GameModel")
local sky_module = require("scripts.SkyViewController")
local background_module = require("scripts.Background")
local earth_module = require("scripts.EarthViewController")
local camera_module = require("scripts.util.Camera")
local controls_module = require("scripts.Controls")
local bullet_module = require("scripts.Bullet")
local wind_module = require("scripts.Wind")

local game = game_module.GameModel:new()

local splash = require("scripts.splash")
local sky = display.newGroup()
sky.distanceRatio = 0.4
local background = display.newGroup()
background.distanceRatio = 0.7
local world = display.newGroup()
world.distanceRatio = 1.0

-- todo sergey: move to a specific object
local controls1
local controls2

-- Main game loop
local function gameLoop()

    if (game.state.name == "P1") then
        controls1:render()
    elseif (game.state.name == "BULLET1" or game.state.name == "BULLET2") then
        if (game.bullet ~= nil and not game.bullet:isAlive()) then
            game.bullet:remove()
            game.bullet = nil
            if (game.state.name == "BULLET1") then
                game:goto("MOVE_TO_P2")
            else
                game:goto("MOVE_TO_P1")
            end
        end
    elseif (game.state.name == "MOVE_TO_P2") then
        game.cameraState = "CASTLE2_FOCUS"
        game:goto("P2")
    elseif (game.state.name == "P2") then
        controls2:render()
    elseif (game.state.name == "MOVE_TO_P1") then
        game.cameraState = "CASTLE1_FOCUS"
        game:goto("P1")
    end
end

local impulse = 11

local fireButtonRelease = function(event)
end

local function cameraListener()
    print("move complete!")
end

local function eventPlayer1Fire()
    controls1:hide()
    local cannonX = game.castle1:cannonX()
    local cannonY = game.castle1:cannonY()
    game.bullet = bullet_module.Bullet:new({game = game, world = world})
    game.bullet:fireBullet(cannonX, cannonY, impulse * math.sin(math.rad(controls1:getAngle())), impulse * math.cos(math.rad(controls1:getAngle())))
    game.cameraState = "CANNONBALL_FOCUS"
end

local function eventPlayer2Fire()
    controls2:hide()
    local cannonX = game.castle2:cannonX()
    local cannonY = game.castle2:cannonY()
    game.bullet = bullet_module.Bullet:new({game = game, world = world})
    game.bullet:fireBullet(cannonX, cannonY, impulse * math.sin(math.rad(controls2:getAngle())), impulse * math.cos(math.rad(controls2:getAngle())))
    game.cameraState = "CANNONBALL_FOCUS"
end

local function eventBulletRemoved()
end

local function eventPlayer1Active()
    game.wind:update()
    controls1:show()
end

local function eventPlayer2Active()
    game.wind:update()
    controls2:show()
end


local function startGame()
    splash.dismissSplashScreen()

    --todo pre-step P1
    game.cameraState = "CASTLE1_FOCUS"

    game:addState({ name = "P1", transitions = {BULLET1 = eventPlayer1Fire} })
    game:addState({ name = "BULLET1", transitions = {MOVE_TO_P2 = eventBulletRemoved} })
    game:addState({ name = "MOVE_TO_P2", transitions = { P2 = eventPlayer2Active} })
    game:addState({ name = "P2", transitions = {BULLET2 = eventPlayer2Fire} })
    game:addState({ name = "BULLET2", transitions = {MOVE_TO_P1 = eventBulletRemoved} })    
    game:addState({ name = "MOVE_TO_P1", transitions = { P1 = eventPlayer1Active } })

    game:setState("P1")

    local camera = camera_module.Camera:new({ game = game, world = world, sky = sky, background = background, listener = cameraListener })

    local skyObj = sky_module.SkyViewController:new()
    skyObj:render(sky, game)

    game.wind = wind_module.Wind:new({ x = 1, y = 1, game = game })
    game.wind:update()

    local backgroundObj = background_module.Background:new()
    backgroundObj:render(background, game)

    local earth = earth_module.EarthViewController:new()
    earth:render(physics, world, game)


    controls1 = controls_module.Controls:new({ world = world, angle = 45, x = game.castle1:cannonX(), y = game.castle1:cannonY()})
    controls2 = controls_module.Controls:new({ world = world, angle = -45, x = game.castle2:cannonX(), y = game.castle2:cannonY()})
    controls1.fireButton:addEventListener("tap", function() game:goto("BULLET1") end)
    controls2.fireButton:addEventListener("tap", function() game:goto("BULLET2") end)

    --    Runtime:addEventListener("collision", onCollision)
    Runtime:addEventListener("enterFrame",
        function()
            camera:moveCamera()
        end)

    timer.performWithDelay(game.delay, gameLoop, 0)
end

splash.splashScreen()
-- splash.fullSplash:addEventListener("tap", startGame)
startGame()

