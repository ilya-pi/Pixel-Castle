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

    local width = display.contentWidth + 2 * display.screenOriginX
    local height = display.contentHeight + 2 * display.screenOriginY
    
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

    infoText( self.game.castle1:healthPercent() .. " %", width / 6, height / 2 + 65, 24, self.displayGroup)
    infoText( self.game.castle2:healthPercent() .. " %", 5 * display.contentWidth / 6, height / 2 + 65, 24, self.displayGroup)

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

    local castle1 = display.newImageRect("images/levels/" .. self.game.levelName .. "/castle1.png", 100, 100)
    self.displayGroup:insert(castle1)
    castle1:setReferencePoint(display.CenterReferencePoint)
    castle1.x = width / 6
    castle1.y = height / 2

    local castle2 = display.newImageRect("images/levels/" .. self.game.levelName .. "/castle2.png", 100, 100)
    self.displayGroup:insert(castle2)
    castle2:setReferencePoint(display.CenterReferencePoint)
    castle2.x = 5 * width / 6
    castle2.y = height / 2
end

function GameOverScreen:dismiss()
    self.displayGroup:removeSelf()
end
