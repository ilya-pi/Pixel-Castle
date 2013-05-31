module(..., package.seeall)

local widget = require("widget")

local Memmory = require("scripts.util.Memmory")
local imageHelper = require("scripts.util.Image")
local customUI = require("scripts.util.CustomUI")

--[[
local CustomUI = require("scripts.util.CustomUI")
CustomUI.checkbox(100, 100, "test", function(event)
    local switch = event.target
    print( switch.id, "is on?:", switch.isOn )
    end)
]]

MainMenuScreen = {} -- required arg: game

-- Constructor
function MainMenuScreen:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    self.assets = imageHelper.loadImageData("data/assets.json")
    self.textMarginTop = 50 --todo: Ilya Pimenov after your last commit this variable disappeared so I'm not sure where it should be
    return o
end

local function infoText(message, x, y, size, group)
    local textShadow = display.newText(message, x + 2, y + 2, "TrebuchetMS-Bold", size)
    local text = display.newText(message, x, y, "TrebuchetMS-Bold", size)
    group:insert(textShadow)
    group:insert(text)
    textShadow:setTextColor(255, 255, 255)
    text:setTextColor(37, 54, 34)
    textShadow.text = message
    text.text = message
end

function MainMenuScreen:render()
    self.displayGroup = display.newGroup()

    local bgHeight = display.contentHeight - 2 * display.screenOriginY
    local bgWidth = bgHeight * 128 / 40

    self.bg = display.newImageRect("images/castle_splash.png", bgWidth, bgHeight)
    self.displayGroup:insert(self.bg)
    self.bg:setReferencePoint(display.TopLeftReferencePoint)
    self.bg.x, self.bg.y = display.screenOriginX, display.screenOriginY

    self.bgMoveLeft = true
    Memmory.timerStash.bgMovementTimer = timer.performWithDelay(30, function()
        if self.bgMoveLeft then
            self.bg.x = self.bg.x - 1
        else
            self.bg.x = self.bg.x + 1
        end

        if (self.bg.x < display.contentWidth - display.screenOriginX - bgWidth) then
            self.bgMoveLeft = false
        elseif (self.bg.x > display.screenOriginX) then
            self.bgMoveLeft = true
        end
    end, 0)

    local overlay = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth - 2 * display.screenOriginX, display.contentHeight - 2 * display.screenOriginY)
    local g = graphics.newGradient({ 236, 0, 140, 150 }, { 0, 114, 88, 175 }, "down")
    overlay:setFillColor(g)
    self.displayGroup:insert(overlay)

end

function MainMenuScreen:showMainMenu()
    self.mainMenuGroup = display.newGroup()
    self.displayGroup:insert(self.mainMenuGroup)

    local play = widget.newButton{
        width = 140,
        height = 40,
        defaultFile = "images/button.png",
        overFile = "images/button_over.png",
        id = "playbtn",
        label = "Play",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = function(event)
            self.game:goto("PLAYMENU")
            return true
        end
    }
    play.x, play.y = 5 * display.contentWidth / 7 + 20, 210
    self.mainMenuGroup:insert(play)

    local options = widget.newButton{
        width = 140,
        height = 40,
        defaultFile = "images/button.png",
        overFile = "images/button_over.png",
        id = "optionsbtn",
        label = "Options",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = function(event)
            self.game:goto("OPTIONS")
            return true
        end
    }
    options.x, options.y = 5 * display.contentWidth / 7 + 20, 260
    self.mainMenuGroup:insert(options)

    --todo: Ilya Pimenov: replace the following code to image as well.
    for i,v in ipairs(imageHelper.renderImage((4 * display.contentWidth / 7) / 5 , 10, self.assets["title"], 5)) do
        self.mainMenuGroup:insert(v)
    end
end

function MainMenuScreen:hideMainMenu()
    self.mainMenuGroup:removeSelf()
    self.mainMenuGroup = nil
end

function MainMenuScreen:showPlayMenu()
    self.playMenuGroup = display.newGroup()
    self.displayGroup:insert(self.playMenuGroup)

    --todo: Ilya Pimenov: replace the following code to image as well.
    for i,v in ipairs(imageHelper.renderImage((4 * display.contentWidth / 7) / 5 , 10, self.assets["title"], 5)) do
        self.playMenuGroup:insert(v)
    end

    local storyMode = widget.newButton{
        width = 170,
        height = 40,
        defaultFile = "images/button.png",
        overFile = "images/button_over.png",
        id = "story_mode_btn",
        label = "Story Mode",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = function(event)
            self.game:goto("LEVELSELECT")
            print("tutorial in story mode")
            return true
        end
    }
    --storyMode.x, storyMode.y = 5 * display.contentWidth / 7 + 20, 260
    storyMode.x, storyMode.y = display.contentWidth / 4, 260  --end of first quater of screen (center of button coords)
    self.playMenuGroup:insert(storyMode)

    local versusMode = widget.newButton{
        width = 170,
        height = 40,
        defaultFile = "images/button.png",
        overFile = "images/button_over.png",
        id = "story_mode_btn",
        label = "Versus Mode",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = function(event)
            self.game:goto("P1")
            print("versus mode")
            return true
        end
    }
    versusMode.x, versusMode.y = display.contentWidth / 4 * 3, 260  --end of third quater of screen (center of button coords)
    self.playMenuGroup:insert(versusMode)

    local backButton = widget.newButton{
        width = 60,
        height = 60,
        defaultFile = "images/menus_common/back_button.png",
        overFile = "images/menus_common/back_button_tapped.png",
        onRelease = function(event)
            self.game:goto("MAINMENU")
            return true
        end
    }
    backButton:setReferencePoint(display.TopLeftReferencePoint)
    backButton.x, backButton.y = display.screenOriginX, display.screenOriginY
    self.playMenuGroup:insert(backButton)
end

function MainMenuScreen:showLevelSelect()
    self.levelSelectGroup = display.newGroup()
    self.levelsGroup = display.newGroup()
    self.levelSelectGroup:insert(self.levelsGroup)

    local levelNumberTextSize = 16
    local levelNumberTextPaddingTop = 2
    local textSize = 28
    local layerSelectMagicYnumber = 15 --it's only one configuration number everything else should be calculated automatically

    local castleSize = 50
    local rawsCount = 3
    local columnsCount = 5

    local levelsGroupViewportWidth = display.contentWidth - 2 * display.screenOriginX
    local levelsGroupViewportHeight = display.contentHeight - 2 * display.screenOriginY - self.textMarginTop - textSize / 2
    local castleXdistance = levelsGroupViewportWidth / (columnsCount + 1)
    local castleYdistance = levelsGroupViewportHeight / (rawsCount + 1)

    customUI.text("Level select", display.contentWidth / 2, self.textMarginTop + display.screenOriginY, textSize, self.levelSelectGroup)

    local levels = self.game.db:getLevels(1) --todo: think about different screens

    for raw = 1, rawsCount do
        for column = 1, columnsCount do
            local levelNumber = (raw - 1) * columnsCount + column
            local castleX, castleY = ((column - 1) * castleXdistance), ((raw - 1) * castleYdistance)
            --local castle = display.newImageRect("images/choose_level/level_select_castle.png", castleSize, castleSize)

            local defaultFile
            local overFile
            local onRelease

            --status - "locked", "new", "done"
            local goto = "P1" --todo: move to db
            if levelNumber == 1 then
                goto = "TUTORIAL"
            end

            if levels[levelNumber].status == "done" then
                --todo: accomplished level
                customUI.text(levelNumber, castleX, castleY + levelNumberTextPaddingTop, levelNumberTextSize, self.levelsGroup)
                defaultFile = "images/choose_level/level_select_castle_accomplished.png"
                overFile = "images/choose_level/level_select_castle_accomplished_pushed.png"
                onRelease = function(event)
                    if event.phase == "ended" then
                        self.game.selectedLevel = levelNumber
                        self.game:goto(goto)
                    end
                end
            elseif levels[levelNumber].status == "new" then
                --todo current level
                customUI.text(levelNumber, castleX, castleY + levelNumberTextPaddingTop, levelNumberTextSize, self.levelsGroup)
                defaultFile = "images/choose_level/level_select_castle_current.png"
                overFile = "images/choose_level/level_select_castle_current_pushed.png"
                onRelease = function(event)
                    if event.phase == "ended" then
                        self.game.selectedLevel = levelNumber
                        self.game:goto(goto)
                    end
                end
            elseif levels[levelNumber].status == "locked" then
                --todo locked level
                defaultFile = "images/choose_level/level_select_castle_locked.png"
                overFile = "images/choose_level/level_select_castle_locked_pushed.png"
                onRelease = function(event)
                    return true
                end
            end

            local castle = widget.newButton{
                width = castleSize,
                height = castleSize,
                defaultFile = defaultFile,
                overFile = overFile,
                onRelease = onRelease
            }
            castle:setReferencePoint(display.CenterReferencePoint)
            castle.x, castle.y = castleX, castleY

            self.levelsGroup:insert(1, castle)

        end
    end
    self.levelsGroup:setReferencePoint(display.CenterReferencePoint)
    self.levelsGroup.x = display.contentWidth / 2
    self.levelsGroup.y = display.contentHeight / 2 + self.textMarginTop - layerSelectMagicYnumber

    local backButton = widget.newButton{
        width = 60,
        height = 60,
        defaultFile = "images/menus_common/back_button.png",
        overFile = "images/menus_common/back_button_tapped.png",
        onRelease = function(event)
            self.game:goto("PLAYMENU")
            return true
        end
    }
    backButton:setReferencePoint(display.TopLeftReferencePoint)
    backButton.x, backButton.y = display.screenOriginX, display.screenOriginY


    self.levelSelectGroup:insert(backButton)
end

function MainMenuScreen:hideLevelSelect()
    self.levelsGroup:removeSelf()
    self.levelsGroup = nil
    self.levelSelectGroup:removeSelf()
    self.levelSelectGroup = nil
end

function MainMenuScreen:hidePlayMenu()
    self.playMenuGroup:removeSelf()
    self.playMenuGroup = nil
end

function MainMenuScreen:showOptionsMenu()
    self.optionsMenuGroup = display.newGroup()
    self.displayGroup:insert(self.optionsMenuGroup)

    local bg = display.newImageRect("images/button.png", 2 * display.contentWidth / 3, display.contentHeight / 2)
    self.optionsMenuGroup:insert(bg)
    bg:setReferencePoint(display.CenterReferencePoint)
    bg.x, bg.y = display.contentWidth / 2, display.contentHeight / 2

    customUI.text("Vibration", display.contentWidth / 6 + 20, display.contentHeight * (1 / 4 + 1/3), 21, self.optionsMenuGroup, display.TopLeftReferencePoint)
    self.optionsMenuGroup:insert(customUI.checkbox(display.contentWidth - display.contentWidth / 6 - 116, display.contentHeight * (1 / 4 + 1/3), "vibrationToggle",
        game.vibration,
        function(event)
            local switch = event.target
            self.game.vibration = switch.isOn
            if switch.isOn then
                system.vibrate()
            end
        end))

    customUI.text("SFX volume", display.contentWidth / 6 + 20, display.contentHeight * (1 / 4 + 1/6) + 5, 21, self.optionsMenuGroup, display.TopLeftReferencePoint)
    self.optionsMenuGroup:insert(customUI.slider(display.contentWidth - display.contentWidth / 6 - 166, display.contentHeight * (1 / 4 + 1/6), 150, "sfxVolumeSlider",
        self.game.sfxVolume,
        function(event)
            local slider = event.target
            local value = event.value
            self.game.sfxVolume = value
        end))

    customUI.text("BGM volume", display.contentWidth / 6 + 20, display.contentHeight / 4, 21, self.optionsMenuGroup, display.TopLeftReferencePoint)
    self.optionsMenuGroup:insert(customUI.slider(display.contentWidth - display.contentWidth / 6 - 166, display.contentHeight / 4 + 5, 150, "bgmVolumeSlider",
        self.game.bgmVolume,
        function(event)
            local slider = event.target
            local value = event.value
            self.game.bgmVolume = value
        end))

    local credits = widget.newButton{
        width = 170,
        height = 40,
        defaultFile = "images/button.png",
        overFile = "images/button_over.png",
        id = "credits_id",
        label = "Credits",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = function(event)
            print("credits clicked")
            return true
        end
    }
    credits.x, credits.y = display.contentWidth / 2, 3 * display.contentHeight / 4 + 30
    self.optionsMenuGroup:insert(credits)

    customUI.text("Options", display.contentWidth / 2, 50 + display.screenOriginY, 30, self.optionsMenuGroup)

    local backButton = widget.newButton{
        width = 60,
        height = 60,
        defaultFile = "images/menus_common/back_button.png",
        overFile = "images/menus_common/back_button_tapped.png",
        onRelease = function(event)
            self.game:goto("MAINMENU")
            return true
        end
    }
    backButton:setReferencePoint(display.TopLeftReferencePoint)
    backButton.x, backButton.y = display.screenOriginX, display.screenOriginY
    self.optionsMenuGroup:insert(backButton)
end

function MainMenuScreen:hideOptionsMenu()
    self.optionsMenuGroup:removeSelf()
    self.optionsMenuGroup = nil
end

function MainMenuScreen:dismiss()
    timer.cancel(Memmory.timerStash.bgMovementTimer)
    if self.bg ~= nil then
        self.bg:removeSelf()
        self.bg = nil
    end

    if self.mainMenuGroup ~= nil then
        self.mainMenuGroup:removeSelf()
        self.mainMenuGroup = nil
    end
    if self.levelsGroup ~= nil then
        self.levelsGroup:removeSelf()
        self.levelsGroup = nil
    end
    if self.levelSelectGroup ~= nil then
        self.levelSelectGroup:removeSelf()
        self.levelSelectGroup = nil
    end
    if self.playMenuGroup ~= nil then
        self.playMenuGroup:removeSelf()
        self.playMenuGroup = nil
    end

    if self.displayGroup ~= nil then
        self.displayGroup:removeSelf()
        self.displayGroup = nil
    end

end
