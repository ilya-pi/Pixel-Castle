module(..., package.seeall)

local widget = require("widget")
local imageHelper = require("scripts.util.Image")

MainMenuScreen = {} -- required arg: game

-- Constructor
function MainMenuScreen:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

local function infoText(message, x, y, size, group)
    local textShadow = display.newText(message, x + 2, y + 2, "TrebuchetMS-Bold", size)
    local text = display.newText(message, x, y, "TrebuchetMS-Bold", size)
    group:insert(textShadow)
    group:insert(text)
    -- textShadow:setReferencePoint(display.CenterReferencePoint)
    -- text:setReferencePoint(display.CenterReferencePoint)
    textShadow:setTextColor(255, 255, 255)
    text:setTextColor(37, 54, 34)
    textShadow.text = message
    text.text = message
end

function MainMenuScreen:render()
    self.displayGroup = display.newGroup()

    local assets = imageHelper.loadImageData("data/assets.json")

    local myPix = (display.contentHeight - 2 * display.screenOriginY) / 40

    self.bgGroup = display.newGroup()
    -- print("xOffset " .. conf.Conf.absXOffset .. " " .. conf.Conf.absYOffset)
    self.displayGroup:insert(self.bgGroup)
    for i,v in ipairs(imageHelper.renderImage(0, 0, assets["castle_splash"], myPix)) do
        self.bgGroup:insert(v)
    end

    -- adjust to real screens
    print(" screen oriing " .. display.screenOriginX .. " " .. display.screenOriginY)
    self.bgGroup.x, self.bgGroup.y = display.screenOriginX, display.screenOriginY

    self.bgMoveLeft = true
    self.bgMovementTimer = timer.performWithDelay(30, function()
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
    self.displayGroup:insert(overlay)
    local g = graphics.newGradient({ 236, 0, 140, 150 }, { 0, 114, 88, 175 }, "down")
    overlay:setFillColor(g)    

    local play = widget.newButton{
        id = "playbtn",
        label = "Play",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        width = 140, height = 40,
        emboss = false,
        color = 65,
        default = "images/button.png",
        over = "images/button.png",
        labelColor = { default = { 255 }, over = { 0 } },
        onEvent = function(event)
            -- todo make transition
                if  (self.game.state.name == "MAINMENU") then    
                    self.game:goto("P1")
                    print("play")
                end
            end
    }
    play.x, play.y = 5 * display.contentWidth / 7 + 20, 260
    self.displayGroup:insert(play)

    local tutorial = widget.newButton{
        id = "tutorialbtn",
        label = "Tutorial",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        width = 140, height = 40,
        emboss = false,
        color = 65,
        default = "images/button.png",
        over = "images/button.png",
        labelColor = { default = { 255 }, over = { 0 } },
        onEvent = function(event)
        -- todo make transition
            if self.game.state.name == "MAINMENU" and event.phase == "release" then
                self.game:goto("TUTORIAL")
            end
            return true
        end
    }
    tutorial.x, tutorial.y = 5 * display.contentWidth / 7 - 140, 260
    self.displayGroup:insert(tutorial)


    for i,v in ipairs(imageHelper.renderImage((4 * display.contentWidth / 7) / 5 , 10, assets["title"], 5)) do
        self.displayGroup:insert(v)
    end

end

function MainMenuScreen: dismiss()
    timer.cancel(self.bgMovementTimer)
    if (self.bgGroup ~= nil) then
        self.bgGroup:removeSelf()
        self.displayGroup:removeSelf()
    end

end
