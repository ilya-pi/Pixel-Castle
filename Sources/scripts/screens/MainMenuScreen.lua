module(..., package.seeall)

local widget = require("widget")

local Memmory = require("scripts.util.Memmory")
local imageHelper = require("scripts.util.Image")

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
        onEvent = function(event)
            if  self.game.state.name == "MAINMENU" and event.phase == "ended" then
                self.game:goto("PLAYMENU")
                print("play menu")
            end
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
        onEvent = function(event)
            if  self.game.state.name == "PLAYMENU" and event.phase == "ended" then
                self.game:goto("TUTORIAL")
                print("tutorial in story mode")
            end
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
        onEvent = function(event)
            if  self.game.state.name == "PLAYMENU" and event.phase == "ended" then
                --self.game:goto("P1") //todo: go to versus mode
                print("versus mode")
            end
        end
    }
    versusMode.x, versusMode.y = display.contentWidth / 4 * 3, 260  --end of third quater of screen (center of button coords)
    self.playMenuGroup:insert(versusMode)

    --todo: add back button
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
