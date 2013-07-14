-- hide status bar
display.setStatusBar(display.HiddenStatusBar)

local widget = require("widget")

physics = require("physics")
--todo: play with the following properties to increase performance
--physics.setPositionIterations( 16 )
--physics.setVelocityIterations( 6 )
physics.start()
-- physics.setTimeStep(0.0004)
physics.setGravity(0, 9.8)
display.setDefault("magTextureFilter", "nearest")
display.setDefault("minTextureFilter", "nearest")

screenHeight = display.contentHeight - 2 * display.screenOriginY
screenWidth = display.contentWidth - 2 * display.screenOriginX
-- physics.setDrawMode( "hybrid" )

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
local turn_module = require("scripts.screens.TurnOverlayScreen")
local tutorial_module = require("scripts.screens.TutorialScreen")

local dbWrapper = require("scripts.db.DbWrapper")

game = game_module.GameModel:new()

game.levelConfig = require("scripts.levels.levelConfig")
local mainMenuScreen = mainmenu_module.MainMenuScreen:new({game = game})
local gameOverScreen = gameover_module.GameOverScreen:new({game = game})
local tutorialScreen = tutorial_module.TutorialScreen:new({game = game})
local pauseMenuOverlay = pausemenu_module.PauseMenuOverlay:new({game = game})
local turnOverlay = turn_module.TurnOverlay:new()

-- Main game loop
local function gameLoop()

    if game.state.name == "P1" then
        -- game.controls1:render()
    elseif (game.state.name == "BULLET1" or game.state.name == "BULLET2") then
        if (game.bullet ~= nil and not game.bullet:isAlive()) then  
            game.bullet:remove()
            game.bullet = nil
            if (game.state.name == "BULLET1") then
                game:goto("HIT1_OVERVIEW")
            else
                game:goto("HIT2_OVERVIEW")
            end
        end
    elseif (game.state.name == "MOVE_TO_P2") then
        -- if game.castle2.events:missed() then
            -- game.castle2:say("missed!")
        -- end
        game.castle1.events:flush()
        game.castle2.events:flush()
        if game.castle1:isDestroyed(game) or game.castle2:isDestroyed(game) then
               game:goto("GAMEOVER")
        else
            game.cameraState = "CASTLE2_FOCUS"
            game:goto("TURN_P2")
        end
    elseif (game.state.name == "P2") then        
        if game.mode == "versus" then
            -- game.controls2:render()            
        elseif game.mode == "campaign" then
            -- todo implement proper AI here
            game:goto("BULLET2")
        end
    elseif (game.state.name == "MOVE_TO_P1") then
        -- if game.castle1.events:missed() then
            -- game.castle1:say("missed!")
        -- end
        game.castle1.events:flush()
        game.castle2.events:flush()

        if game.castle1:isDestroyed(game) or game.castle2:isDestroyed(game) then
               game:goto("GAMEOVER")
        else
            game.cameraState = "CASTLE1_FOCUS"
            game:goto("TURN_P1")
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

    local commonAction = function()
        game.bullet = bullet_module.Bullet:new({game = game})
        game.bullet:fireBullet(cannonX, cannonY, impulse * math.sin(math.rad(game.controls1:getAngle())), impulse * math.cos(math.rad(game.controls1:getAngle())))
        game.cameraState = "CANNONBALL_FOCUS"
    end

    local action = {
        [0] = function() game.castle1:say(">;-E", commonAction) end,
        [1] = function() game.castle1:say("Eat this!", commonAction) end,
        [2] = function() game.castle1:say("ABRVLGH", commonAction) end,
        [3] = function() game.castle1:say("Adios", commonAction) end,
        [4] = commonAction,
        [5] = commonAction,
    }
    action[math.random(1, 99) % 6]()
end

local function eventPlayer2Fire()
    game.controls2:hide()
    local cannonX = game.castle2:cannonX()
    local cannonY = game.castle2:cannonY()

    local commonAction = function()
        game.bullet = bullet_module.Bullet:new({game = game})
        game.bullet:fireBullet(cannonX, cannonY, impulse * math.sin(math.rad(game.controls2:getAngle())), impulse * math.cos(math.rad(game.controls2:getAngle())))
        game.cameraState = "CANNONBALL_FOCUS"
    end

    local action = {
        [0] = function() game.castle2:say(">;-E", commonAction) end,
        [1] = function() game.castle2:say("Eat this!", commonAction) end,
        [2] = function() game.castle2:say("ABRVLGH", commonAction) end,
        [3] = function() game.castle2:say("Adios", commonAction) end,
        [4] = commonAction,
        [5] = commonAction,
    }
    action[math.random(1, 99) % 6]()
end

local function eventBulletRemoved()
    -- game.castle1:updateHealth(game)
    -- game.castle2:updateHealth(game)
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

    game.background.distanceRatio = 0.6
    game.sky.distanceRatio = 0.4
    game.world.distanceRatio = 1.0

    -- Loading game resources
    local levelFileName = game.levelConfig.screens[1].levels[game.selectedLevel].file
    game.level_map = imageHelper.loadImageData("data/" .. levelFileName);

    --todo pre-step P1

    game.skyObj = sky_module.SkyViewController:new()
    game.skyObj:render(game.sky)

    game.backgroundObj = background_module.Background:new()
    game.backgroundObj:render(game.background)

    game.earth = earth_module.EarthViewController:new()
    game.earth:render(physics)

    game.wind = wind_module.Wind:new({ x = 1, y = 1, game = game.game })
    game.wind:update()

    game.levelWidth = game.level_map.levelWidth
    game.levelHeight = game.level_map.levelHeight
    print("level dimentions " ..  game.levelWidth .. " " .. game.levelHeight )
    game.levelName = game.level_map.levelName
    game.level_map = nil

    game.camera = camera_module.Camera:new({ listener = cameraListener })

    game.controls1 = controls_module.Controls:new({ angle = 45, x = game.castle1:cannonX(), y = game.castle1:cannonY(), 
        onFire = function(event)
            if event.phase == "ended" then
                game:goto("BULLET1")
            end
            return true
        end})
    game.controls2 = controls_module.Controls:new({ angle = -45, x = game.castle2:cannonX(), y = game.castle2:cannonY(), 
        onFire = function(event)
            if event.phase == "ended" then
                game:goto("BULLET2")
            end
            return true
        end})
    game.controls1:render()
    game.controls2:render()
    game.controls1:hide()
    game.controls2:hide()

    Runtime:addEventListener("enterFrame", game)

    Memmory.timerStash.gameLoopTimer = timer.performWithDelay(game.delay, gameLoop, 0)

    -- remove loading screen
    loading:removeSelf()
end

local function restartGame()
    gameOverScreen:dismiss()
    cleanup()
    game.cameraState = "OVERVIEW"
    startGame()
    timer.performWithDelay(game.LEVEL_INTRO_DELAY, function()
        pauseMenuOverlay:renderButton()
        game.controls1:show()
        game:goto("TURN_P1")
        end)
end    

local function gameOver()
    pauseMenuOverlay:dismissButton()
    if game.mode == "versus" then
        gameOverScreen:renderVs()
    elseif game.mode == "campaign" then
        gameOverScreen:renderCampaign()
    end
end

local function mainMenu()
    mainMenuScreen:render()
    mainMenuScreen:showMainMenu()
end

local function optionsMenu()
    mainMenuScreen:hideMainMenu()
    mainMenuScreen:showOptionsMenu()
end

local function credits()
    mainMenuScreen:hideOptionsMenu()
    mainMenuScreen:showCredits()
end

local function optionsFromCredits()
    mainMenuScreen:hideCredits()
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
    game.cameraState = "OVERVIEW"
end

local function startGameFromTutorial()
    game.mode = "campaign"
    game.cameraState = "CASTLE1_FOCUS"
    tutorialScreen:dismiss()
    pauseMenuOverlay:renderButton()
    game.controls1:show()
end

local function startCommonGame()
    game.cameraState = "OVERVIEW"
    mainMenuScreen:dismiss()
    startGame()
    timer.performWithDelay(game.LEVEL_INTRO_DELAY, function()
        pauseMenuOverlay:renderButton()
        game.controls1:show()
        game:goto("TURN_P1")
        end)    
end

local function startStoryGameFromLevelSelect()
    game.mode = "campaign"
    startCommonGame()
end

local function startVsGameFromLevelSelect()
    game.mode = "versus"
    startCommonGame()
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

local function levelSelectFromGameover()
    -- mainMenuScreen:hidePlayMenu()
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

local function kickoffLevel()
    game.cameraState = "CASTLE1_FOCUS"
end

local function turnP1()
    turnOverlay:render()
    timer.performWithDelay(1000, function()
            game:goto("P1")
        end)
end

local function turnP2()
    turnOverlay:render()
    timer.performWithDelay(500, function()
            game:goto("P2")
        end)
end

local function turnP1off()
    turnOverlay:dismiss()
end

local function turnP2off()
    turnOverlay:dismiss()
end

local function hit1()
    timer.performWithDelay(1000, function()
        game:goto("MOVE_TO_P2")
    end)    
end

local function hit2()
    timer.performWithDelay(1000, function()
        game:goto("MOVE_TO_P1")
    end)    
end

local function hit1off()
end

local function hit2off()
end

local function init()
    game.selectedLevel = 1

    game.db = dbWrapper.DbWrapper:new()

    game:addStates({  { name = "MAINMENU", transitions = {PLAYMENU = {playMenu}, OPTIONS = {optionsMenu}} },
        { name = "OPTIONS", transitions = {MAINMENU = {mainMenuFromOptions}, CREDITS = {credits}} },
        { name = "CREDITS", transitions = {OPTIONS = {optionsFromCredits}} },
        { name = "PLAYMENU", transitions = {LEVELSELECT = {levelSelectFromPlayMenu}, MAINMENU = {mainMenuFromPlayMenu}, LEVEL_INTRO = {startVsGameFromLevelSelect}} },
        { name = "LEVELSELECT", transitions = {LEVEL_INTRO = {startStoryGameFromLevelSelect}, TUTORIAL = {tutorial}, PLAYMENU = {playMenuFromLevelSelect}} },
        { name = "TUTORIAL", transitions = {TURN_P1 = {startGameFromTutorial, turnP1}} },
        { name = "LEVEL_INTRO", transitions = {TURN_P1 = {kickoffLevel, turnP1}} },
        { name = "TURN_P1", transitions = {P1 = {turnP1off}} },
        { name = "P1", transitions = {BULLET1 = {eventPlayer1Fire}, PAUSEMENU = {pause}} },
        { name = "BULLET1", transitions = {HIT1_OVERVIEW = {eventBulletRemoved, hit1}, PAUSEMENU = {pause}} },
        { name = "HIT1_OVERVIEW", transitions = {MOVE_TO_P2 = {hit1off}} },
        { name = "MOVE_TO_P2", transitions = { TURN_P2 = {eventPlayer2Active, turnP2}, GAMEOVER = {gameOver}, PAUSEMENU = {pause}} },
        { name = "TURN_P2", transitions = {P2 = {turnP2off}} },
        { name = "P2", transitions = {BULLET2 = {eventPlayer2Fire}, PAUSEMENU = {pause}} },
        { name = "BULLET2", transitions = {HIT2_OVERVIEW = {eventBulletRemoved, hit2}, PAUSEMENU = {pause}} },
        { name = "HIT2_OVERVIEW", transitions = {MOVE_TO_P1 = {hit2off}} },
        { name = "MOVE_TO_P1", transitions = { TURN_P1 = {eventPlayer1Active, turnP1}, GAMEOVER = {gameOver}, PAUSEMENU = {pause}} },        
        { name = "PAUSEMENU", transitions = { P1 = {unpause}, BULLET1 = {unpause}, MOVE_TO_P1 = {unpause}, 
        MOVE_TO_P2 = {unpause}, P2 = {unpause}, BULLET2 = {unpause}, MOVE_TO_P1 = {unpause}, MAINMENU = {exitToMain}} },
        { name = "GAMEOVER", transitions = { LEVEL_INTRO = {restartGame}, MAINMENU = {gameOverToMainMenu}}}  })

    game:setState("MAINMENU")

    mainMenuScreen:render()
    mainMenuScreen:showMainMenu()
end

init()

