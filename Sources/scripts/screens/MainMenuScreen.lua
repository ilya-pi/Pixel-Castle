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
    local overlay = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    self.displayGroup:insert(overlay)
    overlay:setFillColor(195, 214, 93, 150)

    infoText("Main Menu", 10, 10, 42, self.displayGroup)

    local play = widget.newButton{
        id = "playbtn",
        label = "Play",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        width = 150, height = 40,
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
    play.x, play.y = 320, 280
    self.displayGroup:insert(play)
end

function MainMenuScreen:dismiss()
    self.displayGroup:removeSelf()
end
