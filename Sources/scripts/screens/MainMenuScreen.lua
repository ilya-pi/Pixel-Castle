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
    self.bgGroup = display.newGroup()
    self.displayGroup:insert(self.bgGroup)


    local myPix = (display.contentHeight - 2 * display.screenOriginY) / 40 --todo: read from imageHeight
    for i,v in ipairs(imageHelper.renderImage(0, 0, self.assets["castle_splash"], myPix)) do
        self.bgGroup:insert(v)
    end
    -- adjust to real screens
    print(" screen oriing " .. display.screenOriginX .. " " .. display.screenOriginY)
    self.bgGroup.x, self.bgGroup.y = display.screenOriginX, display.screenOriginY

    self.bgGroupXright = display.contentWidth - display.screenOriginX - 128 --[[todo: read from imageHeight]] * myPix
    self.bgGroupXleft = display.screenOriginX

--[[
    local loopPhase1
    local loopPhase2
    loopPhase1 = function()
        transition.to( self.bgGroup, { time= transitionTime, x=self.bgGroupXright , onComplete=loopPhase2} )
    end
    loopPhase2 = function()
        transition.to( self.bgGroup, { time= transitionTime, x=self.bgGroupXleft , onComplete=loopPhase1 } )
    end
    loopPhase1()
]]

    self.bgMoveLeft = true
    Memmory.timerStash.bgMovementTimer = timer.performWithDelay(30, function()
        if self.bgMoveLeft then
            self.bgGroup.x = self.bgGroup.x - 1
        else
            self.bgGroup.x = self.bgGroup.x + 1
        end

        if (self.bgGroup.x < display.contentWidth - display.screenOriginX - 128 * myPix) then
            self.bgMoveLeft = false
        elseif (self.bgGroup.x > display.screenOriginX) then
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
    play.x, play.y = 5 * display.contentWidth / 7 + 20, 260
    self.mainMenuGroup:insert(play)

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

    local textMarginTop = 50
    local textSize = 28
    local layerSelectMagicYnumber = 15 --it's only one configuration number everything else should be calculated automatically

    local castleSize = 50
    local rawsCount = 3
    local columnsCount = 5

    local levelsGroupViewportWidth = display.contentWidth - 2 * display.screenOriginX
    local levelsGroupViewportHeight = display.contentHeight - 2 * display.screenOriginY - textMarginTop - textSize / 2
    local castleXdistance = levelsGroupViewportWidth / (columnsCount + 1)
    local castleYdistance = levelsGroupViewportHeight / (rawsCount + 1)

    customUI.text("Level select", display.contentWidth / 2, textMarginTop + display.screenOriginY, textSize, self.levelSelectGroup)

    for raw = 1, rawsCount do
        for column = 1, columnsCount do
            local castle = display.newImageRect("images/choose_level/level_select_castle.png", castleSize, castleSize)
            castle.x, castle.y = ((column - 1) * castleXdistance), ((raw - 1) * castleYdistance)
            if raw == 1 and column == 1 then
                castle:addEventListener("touch",
                    function(event)
                        if event.phase == "ended" then
                            if self.game.state.name == "LEVELSELECT" then
                                self.game:goto("TUTORIAL")
                            else
                                print("Tried going to TUTORIAL two times")
                            end
                        end
                    end
                )
            else
                castle:addEventListener("touch",
                    function(event)
                        if event.phase == "ended" then
                            if self.game.state.name == "LEVELSELECT" then
                                self.game:goto("P1")
                            else
                                print("Tried going to P1 two times")
                            end
                        end
                    end
                )
            end
            self.levelsGroup:insert(castle)
        end
    end
    self.levelsGroup:setReferencePoint(display.CenterReferencePoint)
    self.levelsGroup.x = display.contentWidth / 2
    self.levelsGroup.y = display.contentHeight / 2 + textMarginTop - layerSelectMagicYnumber

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

function MainMenuScreen:dismiss()
    timer.cancel(Memmory.timerStash.bgMovementTimer)
    if self.bgGroupe ~= nil then
        self.bgGroup:removeSelf()
        self.bgGroup = nil
    end

    if self.mainMenuGroup ~= nil then
        self.mainMenuGroup:removeSelf()
        self.mainMenuGroup = nil
    end

    if self.displayGroup ~= nil then
        self.displayGroup:removeSelf()
        self.displayGroup = nil
    end
end
