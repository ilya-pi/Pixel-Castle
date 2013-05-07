-- hide status bar
display.setStatusBar(display.HiddenStatusBar)

physics = require("physics")
physics.start()
physics.setGravity(0, 9.8)

local imageHelper = require("scripts.util.Image")

local game_module = require("scripts.GameModel")
local sky_module = require("scripts.SkyViewController")
local background_module = require("scripts.Background")
local earth_module = require("scripts.EarthViewController")
local camera_module = require("scripts.util.Camera")
local controls_module = require("scripts.Controls")
local bullet_module = require("scripts.Bullet")
local wind_module = require("scripts.Wind")

local gameover_module = require("scripts.screens.GameOverScreen")
local mainmenu_module = require("scripts.screens.MainMenuScreen")

local game = game_module.GameModel:new()

local mainMenuScreen = mainmenu_module.MainMenuScreen:new({game = game})
local gameOverScreen = gameover_module.GameOverScreen:new({game = game})

local splash = require("scripts.splash")
local tutorial = require("scripts.tutorial")

-- Main game loop
local function gameLoop()

    if (game.state.name == "P1") then
        game.controls1:render()
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
        print("castel1 " .. game.castle1:health() .. " castle2 " .. game.castle2:health())
        if game.castle1:isDestroyed(game) or game.castle2:isDestroyed(game) then
               game:goto("GAMEOVER")
        else
            game.cameraState = "CASTLE2_FOCUS"
            game:goto("P2")
        end
    elseif (game.state.name == "P2") then
        game.controls2:render()
    elseif (game.state.name == "MOVE_TO_P1") then
        if game.castle1:isDestroyed(game) or game.castle2:isDestroyed(game) then
               game:goto("GAMEOVER")
        else
            game.cameraState = "CASTLE1_FOCUS"
            game:goto("P1")
        end        
    end
end

local impulse = 11

local fireButtonRelease = function(event)
end

local function cameraListener()
    print("move complete!")
end

local function eventPlayer1Fire()
    game.controls1:hide()
    local cannonX = game.castle1:cannonX()
    local cannonY = game.castle1:cannonY()
    game.bullet = bullet_module.Bullet:new({game = game, world = game.world})
    game.bullet:fireBullet(cannonX, cannonY, impulse * math.sin(math.rad(game.controls1:getAngle())), impulse * math.cos(math.rad(game.controls1:getAngle())))
    game.cameraState = "CANNONBALL_FOCUS"
end

local function eventPlayer2Fire()
    game.controls2:hide()
    local cannonX = game.castle2:cannonX()
    local cannonY = game.castle2:cannonY()
    game.bullet = bullet_module.Bullet:new({game = game, world = game.world})
    game.bullet:fireBullet(cannonX, cannonY, impulse * math.sin(math.rad(game.controls2:getAngle())), impulse * math.cos(math.rad(game.controls2:getAngle())))
    game.cameraState = "CANNONBALL_FOCUS"
end

local function eventBulletRemoved()
    game.castle1:updateHealth(game)
    game.castle2:updateHealth(game)
end

local function eventPlayer1Active()
    game.wind:update()
    game.controls1:show()
end

local function eventPlayer2Active()
    game.wind:update()
    game.controls2:show()
end

local function startGame()
    mainMenuScreen:dismiss()

    game.sky = display.newGroup()
    game.sky.distanceRatio = 0.6
    game.background = display.newGroup()
    game.background.distanceRatio = 0.8
    game.world = display.newGroup()
    game.world.distanceRatio = 1.0

    -- Loading game resources
    game.level_map = imageHelper.loadImageData("data/level1.json");

    --todo pre-step P1
    game.cameraState = "CASTLE1_FOCUS"

    local camera = camera_module.Camera:new({ game = game, world = game.world, sky = game.sky, background = game.background, listener = cameraListener })

    local skyObj = sky_module.SkyViewController:new()
    skyObj:render(game.sky, game)

    game.wind = wind_module.Wind:new({ x = 1, y = 1, game = game.game })
    game.wind:update()

    local backgroundObj = background_module.Background:new()
    backgroundObj:render(game.background, game)

    local earth = earth_module.EarthViewController:new()
    earth:render(physics, game.world, game)

    game.controls1 = controls_module.Controls:new({ world = game.world, angle = 45, x = game.castle1:cannonX(), y = game.castle1:cannonY()})
    game.controls2 = controls_module.Controls:new({ world = game.world, angle = -45, x = game.castle2:cannonX(), y = game.castle2:cannonY()})
    game.controls1.fireButton:addEventListener("tap", function() game:goto("BULLET1") end)
    game.controls2.fireButton:addEventListener("tap", function() game:goto("BULLET2") end)

    --    Runtime:addEventListener("collision", onCollision)
    Runtime:addEventListener("enterFrame",
        function()
            camera:moveCamera()
        end)

    timer.performWithDelay(game.delay, gameLoop, 0)
end

local function restartGame()
    gameOverScreen:dismiss()
    startGame()
end    

local function gameOver()
    gameOverScreen:render()
end

local function mainMenu()
    gameOverScreen:dismiss()
    mainMenuScreen:render()
end    

local function init()

    game:addState({ name = "MAINMENU", transitions = {P1 = startGame}})

    game:addState({ name = "P1", transitions = {BULLET1 = eventPlayer1Fire} })
    game:addState({ name = "BULLET1", transitions = {MOVE_TO_P2 = eventBulletRemoved} })
    game:addState({ name = "MOVE_TO_P2", transitions = { P2 = eventPlayer2Active, GAMEOVER = gameOver} })
    game:addState({ name = "P2", transitions = {BULLET2 = eventPlayer2Fire} })
    game:addState({ name = "BULLET2", transitions = {MOVE_TO_P1 = eventBulletRemoved} })    
    game:addState({ name = "MOVE_TO_P1", transitions = { P1 = eventPlayer1Active, GAMEOVER = gameOver } })
    game:addState({ name = "GAMEOVER", transitions = { P1 = restartGame, MAINMENU = mainMenu } })

    game:setState("MAINMENU")
    mainMenuScreen:render()
end

init()

