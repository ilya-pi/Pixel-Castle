module(..., package.seeall)

local widget = require("widget")
local imageHelper = require("scripts.util.Image")

GameOverScreen = {} -- required arg: game

-- Constructor
function GameOverScreen:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

local function infoText(message, x, y, size, group)
    local textShadow = display.newText(message, x + 2, y + 2, "TrebuchetMS-Bold", size)
    local text = display.newText(message, x, y, "TrebuchetMS-Bold", size)
    textShadow:setReferencePoint(display.CenterReferencePoint)
    text:setReferencePoint(display.CenterReferencePoint)
    textShadow.x, textShadow.y = x + 2, y + 2
    text.x, text.y = x, y
    group:insert(textShadow)
    group:insert(text)
    textShadow:setTextColor(255, 255, 255)
    text:setTextColor(37, 54, 34)
    textShadow.text = message
    text.text = message
end

function GameOverScreen:render()
    self.displayGroup = display.newGroup()
    
    local overlay = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth - 2 * display.screenOriginX, display.contentHeight - 2 * display.screenOriginY)
    self.displayGroup:insert(overlay)
    overlay:setFillColor(195, 214, 93, 150)

    local playerTextShadow = display.newText( ".", display.contentWidth / 2 + 2, display.contentHeight / 4 + 2, "TrebuchetMS-Bold", 48)
    local playerText = display.newText( ".", display.contentWidth / 2, display.contentHeight / 4, "TrebuchetMS-Bold", 48)
    self.displayGroup:insert(playerTextShadow)
    self.displayGroup:insert(playerText)
    playerTextShadow:setReferencePoint(display.CenterReferencePoint)
    playerText:setReferencePoint(display.CenterReferencePoint)
    playerTextShadow:setTextColor(255, 255, 255)
    playerText:setTextColor(37, 54, 34)

    local messageTextShadow = display.newText( ".", display.contentWidth / 2 + 2, display.contentHeight / 4 + 52 + 2, "TrebuchetMS-Bold", 48)
    local messageText = display.newText( ".", display.contentWidth / 2, display.contentHeight / 4 + 52, "TrebuchetMS-Bold", 48)
    self.displayGroup:insert(messageTextShadow)
    self.displayGroup:insert(messageText)
    messageTextShadow:setReferencePoint(display.CenterReferencePoint)
    messageText:setReferencePoint(display.CenterReferencePoint)
    messageTextShadow:setTextColor(255, 255, 255)
    messageText:setTextColor(37, 54, 34)

    if self.game.castle1:isDestroyed(self.game) and self.game.castle2:isDestroyed(self.game) then
        messageTextShadow.text = "Draw!"
        messageText.text = "Draw!"
        playerTextShadow:removeSelf()
        playerText:removeSelf()
    elseif self.game.castle2:isDestroyed(self.game) then
        messageTextShadow.text = "Wins!"
        messageText.text = "Wins!"
        playerTextShadow.text = "Player 1"
        playerText.text = "Player 1"
    else
        messageTextShadow.text = "Wins!"
        messageText.text = "Wins!"
        playerTextShadow.text = "Player 2"
        playerText.text = "Player 2"
    end

    infoText( self.game.castle1:healthPercent() .. " %", display.contentWidth / 6, display.contentHeight / 2 + 42, 24, self.displayGroup)
    infoText( self.game.castle2:healthPercent() .. " %", 5 * display.contentWidth / 6, display.contentHeight / 2 + 42, 24, self.displayGroup)

    local mainMenuBtn = widget.newButton{
        id = "menubtn",
        label = "Main menu",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        width = 150, height = 40,
        defaultFile = "images/button.png",
        overFile = "images/button.png",
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = function(event)
            self.game:goto("MAINMENU")
            return true
        end
    }
    self.displayGroup:insert(mainMenuBtn)
    mainMenuBtn.x, mainMenuBtn.y = 160, 280

    local playAgain = widget.newButton{
        id = "playbtn",
        label = "Play again",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        width = 150, height = 40,
        defaultFile = "images/button.png",
        overFile = "images/button.png",
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = function(event)
            self.game:goto("P1")
            return true
        end
    }
    self.displayGroup:insert(playAgain)
    playAgain.x, playAgain.y = 320, 280
--[[ todo: Ilya Pimenov: render here images of castles instead of creating castles from json. See code below. You should use game here.

    local sky = display.newImageRect("images/levels/" .. game.level_map.levelName .. "/sky.png", game.level_map.levelWidth * game.pixel, game.level_map.levelHeight * game.pixel)
    sky:setReferencePoint(display.TopLeftReferencePoint)
    sky.x = 0
    sky.y = 0
]]

    local castles = imageHelper.loadImageData("data/castles.json") --todo move to static initialization

    for i,v in ipairs(imageHelper.renderImage((display.contentWidth / 6) / 5 - 10, 18, castles["castle1"], 5)) do
        self.displayGroup:insert(v)
    end
    for i,v in ipairs(imageHelper.renderImage((5 * display.contentWidth / 6) / 5 - 8, 18, castles["castle2"], 5)) do
        self.displayGroup:insert(v)
    end
end

function GameOverScreen:dismiss()
    self.displayGroup:removeSelf()
end
