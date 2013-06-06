-- hide status bar
display.setStatusBar(display.HiddenStatusBar)

local widget = require("widget")

physics = require("physics")
--todo: play with the following properties to increase performance
--physics.setPositionIterations( 16 )
--physics.setVelocityIterations( 6 )
physics.start()
physics.setGravity(0, 9.8)
display.setDefault("magTextureFilter", "nearest")
display.setDefault("minTextureFilter", "nearest")

screenHeight = display.contentHeight - 2 * display.screenOriginY
screenWidth = display.contentWidth - 2 * display.screenOriginX
--physics.setDrawMode( "hybrid" )

local Memmory = require("scripts.util.Memmory")
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
local pausemenu_module = require("scripts.screens.PauseMenuOverlay")
local tutorial_module = require("scripts.screens.TutorialScreen")

local levelConfig = require("scripts.levels.levelConfig")
local dbWrapper = require("scripts.db.DbWrapper")

game = game_module.GameModel:new()

local mainMenuScreen = mainmenu_module.MainMenuScreen:new({game = game})
local gameOverScreen = gameover_module.GameOverScreen:new({game = game})
local tutorialScreen = tutorial_module.TutorialScreen:new({game = game})
local pauseMenuOverlay = pausemenu_module.PauseMenuOverlay:new({game = game})

-- Main game loop
local function gameLoop()

    if game.state.name == "P1" then
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
        if game.castle2.events:missed() then
            game.castle2:showBubble(game, "missed!")
        end
        game.castle1.events:flush()
        game.castle2.events:flush()
        if game.castle1:isDestroyed(game) or game.castle2:isDestroyed(game) then
               game:goto("GAMEOVER")
        else
            game.cameraState = "CASTLE2_FOCUS"
            game:goto("P2")
        end
    elseif (game.state.name == "P2") then
        -- todo implement proper AI here
        game:goto("BULLET2")
        game.controls2:render()
    elseif (game.state.name == "MOVE_TO_P1") then
        if game.castle1.events:missed() then
            game.castle1:showBubble(game, "missed!")
        end
        game.castle1.events:flush()
        game.castle2.events:flush()

        if game.castle1:isDestroyed(game) or game.castle2:isDestroyed(game) then
               game:goto("GAMEOVER")
        else
            game.cameraState = "CASTLE1_FOCUS"
            game:goto("P1")
        end        
    end
end

local impulse = 11

local function cameraListener()
    print("move complete!")
end

local function eventPlayer1Fire()
    game.controls1:hide()
    local cannonX = game.castle1:cannonX()
    local cannonY = game.castle1:cannonY()
    game.bullet = bullet_module.Bullet:new({game = game})
    game.bullet:fireBullet(cannonX, cannonY, impulse * math.sin(math.rad(game.controls1:getAngle())), impulse * math.cos(math.rad(game.controls1:getAngle())))
    game.cameraState = "CANNONBALL_FOCUS"
end

local function eventPlayer2Fire()
    game.controls2:hide()
    local cannonX = game.castle2:cannonX()
    local cannonY = game.castle2:cannonY()
    game.bullet = bullet_module.Bullet:new({game = game})
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

local function cleanGroups ( curGroup, level )
    if curGroup ~= nil and curGroup.numChildren then
        while curGroup.numChildren > 0 do
                cleanGroups ( curGroup[curGroup.numChildren], level+1 )
        end
        if level > 0 then
            if curGroup.touch then
                curGroup:removeEventListener( "touch", o )
                curGroup.touch = nil
            end
            curGroup:removeSelf()
        end
    elseif curGroup ~= nil then
            if curGroup.touch then
                curGroup:removeEventListener( "touch", o )
                curGroup.touch = nil
            end
            curGroup:removeSelf()
            curGroup = nil
        return
    end
end

local function cleanup()
    Memmory.cancelAllTimers()
    Memmory.cancelAllTransitions()

    print("removed focking eventerFrame")
    Runtime:removeEventListener("enterFrame", game)

    game.level_map = nil
    game.cameraState = nil
    game.camera = nil
    if game.bullet ~= nil then
        game.bullet:remove()
        game.bullet = nil
    end

    game.controls1 = nil
    game.controls2 = nil

    display.remove(game.sky)
    display.remove(game.background)

    Memmory.clearPhysics()

    -- cleanGroups(game.world, 0)       
    display.remove(game.world)
    game.world = nil    

    Memmory.monitorMem()
end

local function startGame()
    game.sky = display.newGroup()
    game.sky.x = 0
    game.sky.y = 0
    game.background = display.newGroup()
    game.background.x = 0
    game.background.y = 0
    game.world = display.newGroup()
    game.world.x = 0
    game.world.y = 0

    -- add loading screen
    local loading = display.newGroup()
    local overlay = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth - 2 * display.screenOriginX, display.contentHeight - 2 * display.screenOriginY)
    local g = graphics.newGradient({ 236, 0, 140, 150 }, { 0, 114, 88, 175 }, "down")
    overlay:setFillColor(g)
    loading:insert(overlay)
    local spinner = widget.newSpinner{left = display.contentWidth / 2 - 50, top = display.contentHeight / 2 - 50, width = 100, height = 100}
    spinner:start()
    loading:insert(spinner)

    game.background.distanceRatio = 0.8
    game.sky.distanceRatio = 0.6
    game.world.distanceRatio = 1.0

    -- Loading game resources
    local levelFileName = levelConfig.screens[1].levels[game.selectedLevel].file
    game.level_map = imageHelper.loadImageData("data/" .. levelFileName);

    --todo pre-step P1

    local skyObj = sky_module.SkyViewController:new()
    skyObj:render(game.sky)

    local backgroundObj = background_module.Background:new()
    backgroundObj:render(game.background)

    local earth = earth_module.EarthViewController:new()
    earth:render(physics)

    game.wind = wind_module.Wind:new({ x = 1, y = 1, game = game.game })
    game.wind:update()
    pauseMenuOverlay:renderButton()

    game.levelWidth = game.level_map.levelWidth
    game.levelHeight = game.level_map.levelHeight
    print("level dimentions " ..  game.levelWidth .. " " .. game.levelHeight )
    game.levelName = game.level_map.levelName
    game.level_map = nil

    game.camera = camera_module.Camera:new({ listener = cameraListener })

    game.controls1 = controls_module.Controls:new({ angle = 45, x = game.castle1:cannonX(), y = game.castle1:cannonY()})
    game.controls2 = controls_module.Controls:new({ angle = -45, x = game.castle2:cannonX(), y = game.castle2:cannonY()})
--[[
    print("rendered conrols 1" .. game.castle1:cannonX() .. " " .. game.castle1:cannonY())
    print("rendered conrols 2" .. game.castle2:cannonX() .. " " .. game.castle2:cannonY())
]]
    game.controls1.fireButton:addEventListener("touch",
        function(event)
            if event.phase == "ended" then
                game:goto("BULLET1")
            end
            return true
        end
    )
    game.controls2.fireButton:addEventListener("touch",
        function(event)
            if event.phase == "ended" then
                game:goto("BULLET2")
            end
            return true
        end
    )

    Runtime:addEventListener("enterFrame", game)

    Memmory.timerStash.gameLoopTimer = timer.performWithDelay(game.delay, gameLoop, 0)

    -- remove loading screen
    loading:removeSelf()
end

local function restartGame()
    gameOverScreen:dismiss()
    cleanup()
    startGame()
end    

local function gameOver()
    pauseMenuOverlay:dismissButton()
    gameOverScreen:render()
end

local function mainMenu()
    mainMenuScreen:render()
    mainMenuScreen:showMainMenu()
end

local function optionsMenu()
    mainMenuScreen:hideMainMenu()
    mainMenuScreen:showOptionsMenu()
end

local function mainMenuFromOptions()
    mainMenuScreen:hideOptionsMenu()
    mainMenuScreen:showMainMenu()
end

local function gameOverToMainMenu()
    gameOverScreen:dismiss()
    cleanup()
    mainMenu()
end

local function tutorial()
    mainMenuScreen:dismiss()
    startGame()
    tutorialScreen:render()
end

local function startGameFromTutorial()
    game.cameraState = "CASTLE1_FOCUS"
    tutorialScreen:dismiss()
end

local function startStoryGameFromLevelSelect()
    game.cameraState = "CASTLE1_FOCUS"
    mainMenuScreen:dismiss()
    startGame()
end

local function playMenu()
    mainMenuScreen:hideMainMenu()
    mainMenuScreen:showPlayMenu()
end

local function mainMenuFromPlayMenu()
    mainMenuScreen:hidePlayMenu()
    mainMenuScreen:showMainMenu()
end

local function levelSelectFromPlayMenu()
    mainMenuScreen:hidePlayMenu()
    mainMenuScreen:showLevelSelect()
end

local function playMenuFromLevelSelect()
    mainMenuScreen:hideLevelSelect()
    mainMenuScreen:showPlayMenu()
end

local function pause()
    pauseMenuOverlay:dismissButton()
    pauseMenuOverlay:renderPauseScreen()
    physics.pause()
    timer.pause(Memmory.timerStash.gameLoopTimer)
end

local function unpause()
    physics.start()
    timer.resume(Memmory.timerStash.gameLoopTimer)
    pauseMenuOverlay:dismissPauseScreen()    
    pauseMenuOverlay:renderButton()
end

local function exitToMain()
    unpause()
    cleanup()
    mainMenuScreen:render()
    mainMenuScreen:showMainMenu()
end

local function init()
    game.selectedLevel = 1

    game.db = dbWrapper.DbWrapper:new()

    game:addState({ name = "MAINMENU", transitions = {PLAYMENU = playMenu, OPTIONS = optionsMenu}})
    game:addState({ name = "OPTIONS", transitions = {MAINMENU = mainMenuFromOptions}})

    game:addState({ name = "PLAYMENU", transitions = {LEVELSELECT = levelSelectFromPlayMenu, MAINMENU = mainMenuFromPlayMenu, P1 = startStoryGameFromLevelSelect} })
    game:addState({ name = "LEVELSELECT", transitions = {P1 = startStoryGameFromLevelSelect, TUTORIAL = tutorial, PLAYMENU = playMenuFromLevelSelect} })
    game:addState({ name = "TUTORIAL", transitions = {P1 = startGameFromTutorial} })

    game:addState({ name = "P1", transitions = {BULLET1 = eventPlayer1Fire, PAUSEMENU = pause} })
    game:addState({ name = "BULLET1", transitions = {MOVE_TO_P2 = eventBulletRemoved, PAUSEMENU = pause} })
    game:addState({ name = "MOVE_TO_P2", transitions = { P2 = eventPlayer2Active, GAMEOVER = gameOver, PAUSEMENU = pause} })
    game:addState({ name = "P2", transitions = {BULLET2 = eventPlayer2Fire, PAUSEMENU = pause} })
    game:addState({ name = "BULLET2", transitions = {MOVE_TO_P1 = eventBulletRemoved, PAUSEMENU = pause} })    
    game:addState({ name = "MOVE_TO_P1", transitions = { P1 = eventPlayer1Active, GAMEOVER = gameOver, PAUSEMENU = pause} })

    game:addState({ name = "PAUSEMENU", transitions = { P1 = unpause, BULLET1 = unpause, MOVE_TO_P1 = unpause, 
        MOVE_TO_P2 = unpause, P2 = unpause, BULLET2 = unpause, MOVE_TO_P1 = unpause, MAINMENU = exitToMain} })

    game:addState({ name = "GAMEOVER", transitions = { P1 = restartGame, MAINMENU = gameOverToMainMenu } })

    game:setState("MAINMENU")
    mainMenuScreen:render()
    mainMenuScreen:showMainMenu()
end

init()

