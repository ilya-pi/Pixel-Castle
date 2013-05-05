module(..., package.seeall)

local widget = require("widget")

GameOverScreen = {} -- required arg: game

-- Constructor
function GameOverScreen:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

local function infoText(message, x, y, size)
    local textShadow = display.newText(message, x + 2, y + 2, "Trebuchet MS Bold", size)
    local text = display.newText(message, x, y, "Trebuchet MS Bold", size)
    -- textShadow:setReferencePoint(display.CenterReferencePoint)
    -- text:setReferencePoint(display.CenterReferencePoint)
    textShadow:setTextColor(255, 255, 255)
    text:setTextColor(37, 54, 34)
    textShadow.text = message
    text.text = message
end

function GameOverScreen:render()
    local overlay = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    overlay:setFillColor(195, 214, 93, 150)

    local playerTextShadow = display.newText( ".", display.contentWidth / 2 + 2, display.contentHeight / 4 + 2, "Trebuchet MS Bold", 48)
    local playerText = display.newText( ".", display.contentWidth / 2, display.contentHeight / 4, "Trebuchet MS Bold", 48)
    playerTextShadow:setReferencePoint(display.CenterReferencePoint)
    playerText:setReferencePoint(display.CenterReferencePoint)
    playerTextShadow:setTextColor(255, 255, 255)
    playerText:setTextColor(37, 54, 34)

    local messageTextShadow = display.newText( ".", display.contentWidth / 2 + 2, display.contentHeight / 4 + 52 + 2, "Trebuchet MS Bold", 48)
    local messageText = display.newText( ".", display.contentWidth / 2, display.contentHeight / 4 + 52, "Trebuchet MS Bold", 48)
    messageTextShadow:setReferencePoint(display.CenterReferencePoint)
    messageText:setReferencePoint(display.CenterReferencePoint)
    messageTextShadow:setTextColor(255, 255, 255)
    messageText:setTextColor(37, 54, 34)

    if self.game.castle1:isDestroyed(self.game) and self.game.castle2:isDestroyed(self.game) then
        messageTextShadow.text = "Draw!"
        messageText.text = "Draw!"
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

    infoText(self.game.castle1:health() .. " bricks", 10, display.contentHeight / 2 + 42, 24)
    infoText(self.game.castle2:health() .. " bricks", -10 + 3 * display.contentWidth / 4, display.contentHeight / 2 + 42, 24)

    local mainMenuBtn = widget.newButton{
        id = "menubtn",
        label = "Main menu",
        font = "Trebuchet MS Bold",
        fontSize = 24,
        width = 150, height = 40,
        emboss = false,
        color = 65,
        default = "images/button.png",
        over = "images/button.png",
        labelColor = { default = { 255 }, over = { 0 } },
        onEvent = function(event)
                print("main menu")
            end
    }
    mainMenuBtn.x, mainMenuBtn.y = 160, 280

    local playAgain = widget.newButton{
        id = "playbtn",
        label = "Play again",
        font = "Trebuchet MS Bold",
        fontSize = 24,
        width = 150, height = 40,
        emboss = false,
        color = 65,
        default = "images/button.png",
        over = "images/button.png",
        labelColor = { default = { 255 }, over = { 0 } },
        onEvent = function(event)
                print("play again")
            end
    }
    playAgain.x, playAgain.y = 320, 280
end
